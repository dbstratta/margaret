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

  def resolve_star_count(%Story{id: id}, args, _), do: {:ok, Stars.get_star_count(%{story_id: id})}

  def resolve_star_count(%Comment{id: id}, args, _) do
    {:ok, Stars.get_star_count(%{comment_id: id})}
  end

  def resolve_stargazers(%Story{id: story_id} = story, args, _) do
    query = from u in User,
      join: s in Star, on: s.user_id == u.id and s.story_id == ^story_id,
      select: u

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  def resolve_stargazers(%Comment{id: comment_id} = story, args, _) do
    query = from u in User,
      join: s in Star, on: s.user_id == u.id and s.comment_id == ^comment_id,
      select: u

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  def resolve_star(_, %{context: %{user: nil}}), do: Helpers.GraphQLErrors.unauthorized()

  def resolve_star(%{starrable_id: %{type: :story, id: story_id}}, %{context: %{user: user}}) do
    Stars.create_star(%{user_id: user.id, story_id: story_id})
    {:ok, %{starrable: Stories.get_story!(story_id)}}
  end

  def resolve_star(%{starrable_id: %{type: :comment, id: comment_id}}, %{context: %{user: user}}) do
    Stars.create_star(%{user_id: user.id, comment_id: comment_id})
    {:ok, %{starrable: Comments.get_comment!(comment_id)}}
  end

  def resolve_unstar(_, %{context: %{user: nil}}), do: Helpers.GraphQLErrors.unauthorized()

  def resolve_unstar(%{starrable_id: %{type: :story, id: story_id}}, %{context: %{user: user}}) do
    Stars.delete_star(user_id: user.id, story_id: story_id)
    {:ok, %{starrable: Stories.get_story!(story_id)}}
  end

  def resolve_unstar(%{starrable_id: %{type: :comment, id: id}}, %{context: %{user: user}}) do
    Stars.delete_star(user_id: user.id, comment_id: id)
    {:ok, %{starrable: Comment.get_comment!(id)}}
  end
end
