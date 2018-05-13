defmodule Margaret.Stars.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{Accounts, Stories, Comments, Stars}
  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment
  alias Stars.Star

  @doc """
  """
  def starred(%{user: %User{id: user_id}} = args) do
    type = Map.get(args, :type, :all)

    query = from(star in Star, where: star.user_id == ^user_id)

    case type do
      :all ->
        query
        |> join(:left, [star], story in assoc(star, :story))
        |> join(:left, [star], comment in assoc(star, :comment))
        |> select([star, story, comment], {[story, comment], %{starred_at: star.inserted_at}})

      :story ->
        query
        |> join(:inner, [star], story in assoc(star, :story))
        |> select([star, story], {story, %{starred_at: star.inserted_at}})

      :comment ->
        query
        |> join(:inner, [star], comment in assoc(star, :comment))
        |> select([star, comment], {comment, %{starred_at: star.inserted_at}})
    end
  end

  def stargazers(args) do
    query =
      from(
        u in User,
        join: s in assoc(u, :stars),
        select: {u, %{starred_at: s.inserted_at}}
      )

    query
    |> maybe_filter_active_stargazers(args)
    |> filter_by_followable(args)
  end

  defp maybe_filter_active_stargazers(query, args) do
    if Map.get(args, :active_only, true) do
      from(u in query, where: is_nil(u.deactivated_at))
    else
      query
    end
  end

  defp filter_by_followable(query, %{story: %Story{id: story_id}}),
    do: from([_u, star] in query, where: star.story_id == ^story_id)

  defp filter_by_followable(query, %{comment: %Comment{id: comment_id}}),
    do: from([_u, star] in query, where: star.comment_id == ^comment_id)
end
