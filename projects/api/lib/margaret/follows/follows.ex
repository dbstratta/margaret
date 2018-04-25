defmodule Margaret.Follows do
  @moduledoc """
  The Follows context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Follows,
    Publications,
    Notifications
  }

  alias Accounts.User
  alias Follows.Follow
  alias Publications.Publication

  @type followable :: User.t() | Publication.t()

  @doc """
  Gets a follow.

  ## Examples

      iex> get_follow(123)
      %Follow{}

      iex> get_follow(456)
      nil

      iex> get_follow(follower_id: 123, publication_id: 123)
      %Follow{}

      iex> get_follow(follower_id: 456, user_id: 345)
      nil

  """
  @spec get_follow(String.t() | non_neg_integer) :: Follow.t() | nil
  def get_follow(id) when not is_list(id), do: Repo.get(Follow, id)

  @spec get_follow(Keyword.t()) :: Follow.t() | nil
  def get_follow(clauses) when length(clauses) == 2, do: Repo.get_by(Follow, clauses)

  def followable(%Follow{user_id: user_id} = follow) when not is_nil(user_id) do
    follow
    |> Follow.preload_user()
    |> Map.fetch!(:user)
  end

  def followable(%Follow{publication_id: publication_id} = follow)
      when not is_nil(publication_id) do
    follow
    |> Follow.preload_publication()
    |> Map.fetch!(:publication)
  end

  @doc """
  Gets all the followers of a followee.
  """
  @spec followers(User.t() | Publication.t()) :: [User.t()]
  def followers(followee) do
    followee
    |> Follow.by_followee()
    |> Repo.all()
  end

  @doc """
  Gets the followee count of a user.

  ## Examples

    iex> followee_count(%User{})
    42

  """
  @spec followee_count(User.t()) :: non_neg_integer()
  def followee_count(%User{} = user) do
    user
    |> Follow.by_follower()
    |> Repo.count()
  end

  @doc """
  Gets the follower count of a followable.

  ## Examples

    iex> follower_count(user: %User{})
    42

    iex> follower_count(publication: %Publication{})
    815

  """
  @spec follower_count(Keyword.t()) :: non_neg_integer
  def follower_count(clauses) do
    query =
      clauses
      |> get_followable_from_clauses()
      |> case do
        %User{} = user -> Follow.by_user(user)
        %Publication{} = publication -> Follow.by_publication(publication)
      end

    query
    |> join(:inner, [c], u in assoc(c, :follower))
    |> User.active()
    |> Repo.count()
  end

  @doc """
  Returns `true` if the user has followed the followable.
  `false` otherwise.

  ## Examples

      iex> has_followed?(follower: %User{}, user: %User{})
      true

      iex> has_followed?(follower: %User{}, publication: %Publication{})
      false

  """
  @spec has_followed?(Keyword.t()) :: boolean
  def has_followed?(clauses) do
    %User{id: follower_id} = Keyword.get(clauses, :follower)

    clauses =
      clauses
      |> get_followable_from_clauses()
      |> case do
        %User{id: user_id} -> [user_id: user_id]
        %Publication{id: publication_id} -> [publication_id: publication_id]
      end
      |> Keyword.put(:follower_id, follower_id)

    !!get_follow(clauses)
  end

  @doc """
  Returns `true` if the follower can follow the followable.
  `false` otherwise.
  """
  @spec can_follow?(Keyword.t()) :: boolean
  def can_follow?(clauses) do
    %User{id: follower_id} = Keyword.get(clauses, :follower)

    clauses
    |> get_followable_from_clauses()
    |> case do
      %User{id: user_id} when user_id == follower_id -> false
      _ -> true
    end
  end

  @spec get_followable_from_clauses(Keyword.t()) :: followable
  defp get_followable_from_clauses(clauses) do
    cond do
      Keyword.has_key?(clauses, :user) -> Keyword.get(clauses, :user)
      Keyword.has_key?(clauses, :publication) -> Keyword.get(clauses, :publication)
    end
  end

  @doc """
  Inserts a follow.
  """
  def insert_follow(attrs) do
    follow_changeset = Follow.changeset(attrs)

    Multi.new()
    |> Multi.insert(:follow, follow_changeset)
    |> notify_followee_of_follow()
    |> Repo.transaction()
  end

  # If the followee is an user, it notifies that user.
  # If it's a publication, it notifies the owner of
  # that publication.
  @spec notify_followee_of_follow(Multi.t()) :: Multi.t()
  defp notify_followee_of_follow(multi) do
    insert_notification = fn %{follow: follow} ->
      followable = followable(follow)

      followee =
        case followable do
          %User{} = user -> user
          %Publication{} = publication -> Publications.owner(publication)
        end

      notified_users = [followee]

      notification_attrs =
        followable
        |> case do
          %User{id: user_id} -> %{user_id: user_id}
          %Publication{id: publication_id} -> %{publication_id: publication_id}
        end
        |> Map.merge(%{
          actor_id: follow.follower_id,
          action: "followed",
          notified_users: notified_users
        })

      case Notifications.insert_notification(notification_attrs) do
        {:ok, %{notification: notification}} -> {:ok, notification}
        {:error, _, reason, _} -> {:error, reason}
      end
    end

    Multi.run(multi, :notification_of_follow, insert_notification)
  end

  @doc """
  Deletes a follow.

  ## Examples

    iex> delete_follow(%Follow{})
    {:ok, %Follow{}}

  """
  def delete_follow(%Follow{} = follow), do: Repo.delete(follow)
end
