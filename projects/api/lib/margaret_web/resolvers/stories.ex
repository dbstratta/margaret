defmodule MargaretWeb.Resolvers.Stories do
  @moduledoc """
  The Story GraphQL resolvers.
  """

  import MargaretWeb.Helpers.GraphQLErrors, only: [unauthorized: 0]
  alias Margaret.Stories

  def resolve_story(%{slug: slug}, _) do
    Stories.get_story(slug)
  end

  def resolve_create_story(args, %{context: %{user: user}}) do
    case Stories.create_story(args) do
      {:ok, story} -> story
      {:error, changeset} -> {:error, changeset}
    end
  end

  def resolve_create_story(_, _), do: unauthorized()
end
