defmodule Margaret.Follows do
  @moduledoc """
  The Follows context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{Repo, Accounts, Follows, Publications, Workers}
  alias Accounts.User
  alias Follows.Follow
  alias Publications.Publication

  @doc """
  Gets a follow.

  ## Examples

      iex> get_follow(123)
      %Follow{}

      iex> get_follow(456)
      nil

      iex> get_follow(123, publication_id: 123)
      %Follow{}

      iex> get_follow(456, user_id: 345)
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
      cond do
        Keyword.has_key?(clauses, :user) ->
          clauses
          |> Keyword.get(:user)
          |> Follow.by_user()

        Keyword.has_key?(clauses, :publication) ->
          clauses
          |> Keyword.get(:publication)
          |> Follow.by_publication()
      end

    query
    |> join(:inner, [c], u in assoc(c, :author))
    |> User.active()
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Inserts a follow.

  ## Examples

    iex> insert_follow(attrs)
    {:ok, %Follow{}}

    iex> insert_follow(attrs)
    {:error, %Ecto.Changeset{}}

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
