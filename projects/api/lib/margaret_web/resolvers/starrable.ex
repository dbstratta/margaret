defmodule MargaretWeb.Resolvers.Starrable do
  @moduledoc """
  The Starrable GraphQL resolvers.
  """

  alias Margaret.{Accounts, Stories, Stars, Comments}
  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment
  alias MargaretWeb.Helpers

  def resolve_star_count(%Story{id: id}, args, _), do: {:ok, Stars.get_star_count(%{story_id: id})}

  def resolve_star_count(%Comment{id: id}, args, _) do
    {:ok, Stars.get_star_count(%{comment_id: id})}
  end

  def resolve_stargazers(%Story{} = story, args, _) do

  end

  def resolve_star(%{starrable_id: %{type: :story, id: story_id}}, %{context: %{user: user}}) do
    Stars.create_star(%{user_id: user.id, story_id: story_id})
    {:ok, %{starrable: Stories.get_story!(story_id)}}
  end

  def resolve_star(%{type: :comment, id: id}, %{context: %{user: %User{} = user}}) do

  end

  def resolve_star(_, %{context: %{user: nil}}), do: Helpers.GraphQLErrors.unauthorized()

  def resolve_unstar(%{starrable_id: %{type: :story, id: story_id}}, %{context: %{user: user}}) do
    Stars.delete_star(user_id: user.id, story_id: story_id)
    {:ok, %{starrable: Stories.get_story!(story_id)}}
  end

  def resolve_unstar(_, %{context: %{user: nil}}), do: Helpers.GraphQLErrors.unauthorized()
end
