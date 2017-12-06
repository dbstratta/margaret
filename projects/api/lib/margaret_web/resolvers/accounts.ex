defmodule MargaretWeb.Resolvers.Accounts do
  @moduledoc """
  The Account GraphQL resolvers.
  """

  import MargaretWeb.Helpers.GraphQLErrors, only: [unauthorized: 0]

  @doc """
  Resolves the currently logged in user.
  """
  def resolve_me(_, %{context: %{user: me}} = resolution),
    do: resolve_user(%{username: me.username}, resolution)

  def resolve_me(_, _), do: unauthorized()

  @doc """
  Resolves a user by its username.
  """
  def resolve_user(%{username: username}, _) do
    # TODO
  end

  @doc """
  Resolves a user creation.
  """
  def resolve_create_user(%{}) do
    # TODO
  end
end
