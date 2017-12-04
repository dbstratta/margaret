defmodule MargaretWeb.Resolvers.Accounts do
  @moduledoc """
  The Account GraphQL resolvers.
  """

  alias MargaretWeb.Utils.ErrorMessages

  @doc """
  Resolves the currently logged in user.
  """
  def resolve_me(_, %{context: %{user: user}} = resolution),
    do: resolve_user(%{id: user.id}, resolution)

  def resolve_me(_, _), do: ErrorMessages.unauthorized()

  @doc """
  Resolves a user by its username.
  """
  def resolve_user(%{username: username}, _) do
    # TODO
  end

  def create_user(%{}) do
    # TODO
  end
end
