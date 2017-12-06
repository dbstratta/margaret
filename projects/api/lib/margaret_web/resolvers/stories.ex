defmodule MargaretWeb.Resolvers.Stories do
  @moduledoc """
  The Story GraphQL resolvers.
  """

  import MargaretWeb.Helpers.GraphQLErrors, only: [unauthorized: 0]
  alias Margaret.Stories

  def resolve_story(%{}, _) do
    # TODO
  end

  def resolve_create_story(_, %{context: %{user: user}}) do

  end

  def resolve_create_story(_, _), do: unauthorized()
end
