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
    Workers
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
  Inserts a star.
  """
  def insert_star(%{user_id: user_id} = attrs) do
    star_changeset = Star.changeset(attrs)

    notification_attrs =
      attrs
      |> case do
        %{story_id: story_id} -> %{story_id: story_id}
        %{comment_id: comment_id} -> %{comment_id: comment_id}
      end
      |> Map.put(:actor_id, user_id)
      |> Map.put(:action, :starred)

    Multi.new()
    |> Multi.insert(:star, star_changeset)
    |> Workers.Notifications.enqueue_notification_insertion(notification_attrs)
    |> Repo.transaction()
  end

  @doc """
  Deletes a star.
  """
  def delete_star(%Star{} = star), do: Repo.delete(star)

  @doc """
  Gets the star count of a starrable.

  ## Examples

      iex> get_star_count(story: %Story{})
      42

      iex> get_star_count(comment: %Comment{})
      0

  """
  def get_star_count(clauses) do
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

  @spec get_starrable_from_clauses(Keyword.t()) :: starrable
  defp get_starrable_from_clauses(clauses) do
    cond do
      Keyword.has_key?(clauses, :story) -> Keyword.get(clauses, :story)
      Keyword.has_key?(clauses, :comment) -> Keyword.get(clauses, :comment)
    end
  end

  @doc """
  Gets the starred count of a user.

  ## Examples

      iex> get_starred_count(%User{})
      42

      iex> get_starred_count(%User{})
      0

  """
  def get_starred_count(%User{} = user) do
    query = Star.by_user(user)

    Repo.aggregate(query, :count, :id)
  end
end
