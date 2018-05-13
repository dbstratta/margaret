defmodule Margaret.Stars do
  @moduledoc """
  The Stars context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Comments,
    Stars,
    Notifications,
    Helpers
  }

  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment
  alias Stars.Star

  @type starrable :: Story.t() | Comment.t()

  @doc """
  Gets a star.

  ## Examples

      iex> get_star(user_id: 123, story_id: 123)
      %Star{}

      iex> get_star(user_id: 123, story_id: 456)
      nil

  """
  @spec get_star(Keyword.t()) :: Star.t() | nil
  def get_star(clauses) when length(clauses) == 2, do: Repo.get_by(Star, clauses)

  @doc """
  Returns the starrable of the star.

  ## Examples

      iex> starrable(%Star{})
      %Story{}

      iex> starrable(%Star{})
      %Comment{}

  """
  @spec starrable(Star.t()) :: Story.t() | Comment.t()
  def starrable(%Star{story_id: story_id} = star) when not is_nil(story_id) do
    star
    |> Star.preload_story()
    |> Map.fetch!(:story)
  end

  def starrable(%Star{comment_id: comment_id} = star) when not is_nil(comment_id) do
    star
    |> Star.preload_comment()
    |> Map.fetch!(:comment)
  end

  @doc """
  Returns `true` if the user has starred the starrable.
  `false` otherwise.

  ## Examples

      iex> has_starred?(user: %User{}, story: %Story{})
      true

      iex> has_starred?(user: %User{}, story: %Story{})
      false

  """
  @spec has_starred?(Keyword.t()) :: boolean
  def has_starred?(clauses) do
    %User{id: user_id} = Keyword.get(clauses, :user)

    clauses =
      clauses
      |> get_starrable_from_clauses()
      |> case do
        %Story{id: story_id} -> [story_id: story_id]
        %Comment{id: comment_id} -> [comment_id: comment_id]
      end
      |> Keyword.put(:user_id, user_id)

    !!get_star(clauses)
  end

  @doc """
  """
  @spec starred(map()) :: any()
  def starred(args) do
    args
    |> Stars.Queries.starred()
    |> Helpers.Connection.from_query(args)
  end

  @doc """
  """
  @spec starred_count(map()) :: non_neg_integer()
  def starred_count(args \\ %{}) do
    args
    |> Stars.Queries.starred()
    |> Repo.count()
  end

  def stargazers(args) do
    args
    |> Stars.Queries.stargazers()
    |> Helpers.Connection.from_query(args)
  end

  @doc """
  Inserts a star.
  """
  @spec insert_star(map()) :: any()
  def insert_star(attrs) do
    star_changeset = Star.changeset(attrs)

    Multi.new()
    |> Multi.insert(:star, star_changeset)
    |> notify_author_of_starrable()
    |> Repo.transaction()
  end

  @spec notify_author_of_starrable(Multi.t()) :: Multi.t()
  defp notify_author_of_starrable(multi) do
    insert_notification = fn %{star: star} ->
      starrable = starrable(star)

      author =
        case starrable do
          %Story{} = story -> Stories.author(story)
          %Comment{} = comment -> Comments.author(comment)
        end

      notified_users = [author]

      notification_attrs =
        starrable
        |> case do
          %Story{id: story_id} -> %{story_id: story_id}
          %Comment{id: comment_id} -> %{comment_id: comment_id}
        end
        |> Map.merge(%{
          actor_id: author.id,
          action: "starred",
          notified_users: notified_users
        })

      case Notifications.insert_notification(notification_attrs) do
        {:ok, %{notification: notification}} -> {:ok, notification}
        {:error, _, reason, _} -> {:error, reason}
      end
    end

    Multi.run(multi, :notification, insert_notification)
  end

  @doc """
  Deletes a star.
  """
  def delete_star(%Star{} = star), do: Repo.delete(star)

  @doc """
  Gets the star count of a starrable.

  ## Examples

      iex> star_count(story: %Story{})
      42

      iex> star_count(comment: %Comment{})
      0

  """
  def star_count(clauses) do
    query =
      clauses
      |> get_starrable_from_clauses()
      |> case do
        %Story{} = story -> Star.by_story(story)
        %Comment{} = comment -> Star.by_comment(comment)
      end

    query
    |> join(:inner, [star], u in assoc(star, :user))
    |> User.active()
    |> Repo.aggregate(:count, :id)
  end

  @spec get_starrable_from_clauses(Keyword.t()) :: starrable()
  defp get_starrable_from_clauses(clauses) do
    cond do
      Keyword.has_key?(clauses, :story) -> Keyword.get(clauses, :story)
      Keyword.has_key?(clauses, :comment) -> Keyword.get(clauses, :comment)
    end
  end
end
