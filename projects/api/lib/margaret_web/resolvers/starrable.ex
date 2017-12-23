defmodule MargaretWeb.Resolvers.Starrable do
  @moduledoc """
  The Starrable GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias Margaret.{Repo, Accounts, Stories, Stars, Comments}
  alias Accounts.User
  alias Stars.Star
  alias Stories.Story
  alias Comments.Comment
  alias MargaretWeb.Helpers

  def resolve_stargazers(%Comment{id: comment_id} = story, args, _) do
    query = from u in User,
      join: s in Star, on: s.user_id == u.id and s.comment_id == ^comment_id,
      select: u

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  def resolve_star(
    %{starrable_id: %{type: :story, id: story_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    story_id
    |> Stories.get_story()
    |> do_resolve_star(viewer_id)
  end

  def resolve_star(
    %{starrable_id: %{type: :comment, id: comment_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    comment_id
    |> Comments.get_comment()
    |> do_resolve_star(viewer_id)
  end

  def resolve_star(_, _), do: Helpers.GraphQLErrors.unauthorized()

  defp do_resolve_star(%Story{id: story_id} = story, viewer_id) do
    Stars.create_star(%{user_id: viewer_id, story_id: story_id})
    {:ok, %{starrable: story}}
  end

  defp do_resolve_star(%Comment{id: comment_id} = comment, viewer_id) do
    Stars.create_star(%{user_id: viewer_id, comment_id: comment_id})
    {:ok, %{starrable: comment}}
  end

  defp do_resolve_star(nil, _), do: {:error, "Starrable doesn't exist."}

  def resolve_unstar(_, %{context: %{user: nil}}), do: Helpers.GraphQLErrors.unauthorized()

  def resolve_unstar(
    %{starrable_id: %{type: :story, id: story_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    Stars.delete_star(user_id: viewer_id, story_id: story_id)
    {:ok, %{starrable: Stories.get_story!(story_id)}}
  end

  def resolve_unstar(
    %{starrable_id: %{type: :comment, id: id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    Stars.delete_star(user_id: viewer_id, comment_id: id)
    {:ok, %{starrable: Comment.get_comment!(id)}}
  end

  def resolve_unstar(_, _), do: Helpers.GraphQLErrors.unauthorized()

  defp do_resolve_unstar(%Story{id: story_id} = story, viewer_id) do
    Stars.delete_star(user_id: viewer_id, story_id: story_id)
    {:ok, %{starrable: story}}
  end

  defp do_resolve_unstar(%Comment{id: comment_id} = comment, viewer_id) do
    Stars.delete_star(user_id: viewer_id, comment_id: comment_id)
    {:ok, %{starrable: comment}}
  end

  defp do_resolve_unstar(nil, _), do: {:error, "Starrable doesn't exist."}
end
