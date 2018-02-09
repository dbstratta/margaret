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
    Workers
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

  @doc """
  Gets the followee count of a user.

  ## Examples

    iex> get_followee_count(%User{})
    42

  """
  @spec get_followee_count(User.t()) :: non_neg_integer
  def get_followee_count(%User{} = user) do
    query = Follow.by_follower(user)

    Repo.aggregate(query, :count, :id)
  end

  @doc """
  Gets the follower count of a followable.

  ## Examples

    iex> get_follower_count([user: %User{}])
    42

    iex> get_follower_count([publication: %Publication{}])
    815

  """
  @spec get_follower_count(Keyword.t()) :: non_neg_integer
  def get_follower_count(clauses) do
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
    |> Repo.aggregate(:count, :id)
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
  def insert_follow(%{follower_id: follower_id} = attrs) do
    follow_changeset = Follow.changeset(attrs)

    notification_attrs =
      attrs
      |> case do
        %{user_id: user_id} -> %{user_id: user_id}
        %{publication_id: publication_id} -> %{publication_id: publication_id}
      end
      |> Map.put(:actor_id, follower_id)
      |> Map.put(:action, :followed)

    Multi.new()
    |> Multi.insert(:follow, follow_changeset)
    |> Workers.Notifications.enqueue_notification_insertion(notification_attrs)
    |> Repo.transaction()
  end

  @doc """
  Deletes a follow.

  ## Examples

    iex> delete_follow(%Follow{})
    {:ok, %Follow{}}

  """
  def delete_follow(%Follow{} = follow), do: Repo.delete(follow)
end
