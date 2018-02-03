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
  def get_follow(id), do: Repo.get(Follow, id)

  @spec get_follow(String.t() | non_neg_integer, Keyword.t()) :: Follow.t() | nil
  def get_follow(follower_id, opts) do
    clauses =
      cond do
        Keyword.has_key?(opts, :publication_id) ->
          [publication_id: Keyword.get(opts, :publication_id)]

        Keyword.has_key?(opts, :user_id) ->
          [user_id: Keyword.get(opts, :user_id)]
      end
      |> Keyword.put(:follower_id, follower_id)

    Repo.get_by(Follow, clauses)
  end

  @doc """
  Gets the followee count of a user.

  ## Examples

    iex> get_followee_count(%User{})
    42

  """
  def get_followee_count(%User{id: user_id}) do
    query = from(f in Follow, where: f.follower_id == ^user_id, select: count(f.id))

    Repo.one!(query)
  end

  @doc """
  Gets the follower count of a followable.

  ## Examples

    iex> get_follower_count(%{user_id: 123})
    42

    iex> get_follower_count(%{publication_id: 234})
    815

  """
  def get_follower_count(%{user_id: user_id}) do
    Repo.one!(from(f in Follow, where: f.user_id == ^user_id, select: count(f.id)))
  end

  def get_follower_count(%{publication_id: publication_id}) do
    Repo.one!(from(f in Follow, where: f.publication_id == ^publication_id, select: count(f.id)))
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

    iex> delete_follow(123)
    {:ok, %Follow{}}

    iex> delete_follow(%{follower_id: 123, publication_id: 234})
    {:ok, %Follow{}}

    iex> delete_follow(%{follower_id: 123, user_id: 234})
    {:error, %Ecto.Changeset{}}

  """
  def delete_follow(%Follow{} = follow), do: Repo.delete(follow)

  def delete_follow(args) do
    case get_follow(args) do
      %Follow{} = follow -> delete_follow(follow)
      nil -> nil
    end
  end
end
