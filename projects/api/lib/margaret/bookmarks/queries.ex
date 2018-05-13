defmodule Margaret.Bookmarks.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{Accounts, Bookmarks}
  alias Accounts.User
  alias Bookmarks.Bookmark

  @doc """
  """
  @spec bookmarked(User.t(), map()) :: Ecto.Query.t()
  def bookmarked(%User{id: user_id}, args \\ %{}) do
    type = Map.get(args, :type, :all)

    query = from(b in Bookmark, where: b.user_id == ^user_id)

    case type do
      :all ->
        query
        |> join(:left, [b], s in assoc(b, :story))
        |> join(:left, [b], c in assoc(b, :comment))
        |> select([b, s, c], {[s, c], %{bookmarked_at: b.inserted_at}})

      :story ->
        query
        |> join(:inner, [b], s in assoc(b, :story))
        |> select([b, s], {s, %{bookmarked_at: b.inserted_at}})

      :comment ->
        query
        |> join(:inner, [b], c in assoc(b, :comment))
        |> select([b, c], {c, %{bookmarked_at: b.inserted_at}})
    end
  end
end
