defmodule Margaret.Follows.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{Accounts, Publications, Follows}
  alias Accounts.User
  alias Publications.Publication
  alias Follows.Follow

  @doc """
  """
  @spec followers(map()) :: Ecto.Query.t()
  def followers(args \\ %{}) do
    query =
      from(
        u in User,
        join: f in Follow,
        on: f.follower_id == u.id,
        select: {u, %{followed_at: f.inserted_at}}
      )

    query
    |> filter_by_followee(args)
    |> maybe_filter_active_followers(args)
  end

  defp filter_by_followee(query, %{user: %User{id: user_id}}),
    do: from([_u, f] in query, where: f.user_id == ^user_id)

  defp filter_by_followee(query, %{publication: %Publication{id: publication_id}}),
    do: from([_u, f] in query, where: f.publication_id == ^publication_id)

  defp maybe_filter_active_followers(query, args) do
    if Map.get(args, :active_only, true) do
      from(u in query, where: is_nil(u.deactivated_at))
    else
      query
    end
  end

  @doc """
  """
  @spec followees(map()) :: Ecto.Query.t()
  def followees(%{follower: %User{id: follower_id}} = args) do
    type = Map.get(args, :type, :all)

    query = from(f in Follow, where: f.follower_id == ^follower_id)

    case type do
      :all ->
        query
        |> join(:left, [f], u in assoc(f, :user))
        |> maybe_filter_active_users(args)
        |> join(:left, [f], p in assoc(f, :publication))
        |> select([f, u, p], {[u, p], %{followed_at: f.inserted_at}})

      :user ->
        query
        |> join(:inner, [f], u in assoc(f, :user))
        |> maybe_filter_active_users(args)
        |> select([f, u], {u, %{followed_at: f.inserted_at}})

      :publication ->
        query
        |> join(:inner, [f], p in assoc(f, :publication))
        |> select([f, p], {p, %{followed_at: f.inserted_at}})
    end
  end

  defp maybe_filter_active_users(query, args) do
    if Map.get(args, :active_users_only, true) do
      from([_f, u] in query, where: is_nil(u.deactivated_at))
    else
      query
    end
  end
end
