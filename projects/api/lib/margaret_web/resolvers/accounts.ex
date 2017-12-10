defmodule MargaretWeb.Resolvers.Accounts do
  @moduledoc """
  The Account GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts}
  alias Accounts.User

  @doc """
  Resolves the currently logged in user.
  """
  def resolve_me(_, %{context: %{user: me}}), do: {:ok, me}
  def resolve_me(_, _), do: Helpers.GraphQLErrors.unauthorized()

  @doc """
  Resolves a user by its username.
  """
  def resolve_user(%{username: username}, _) do
    {:ok, Accounts.get_user_by_usrname(username)}
  end

  @doc """
  Resolves a connection of users.
  """
  def resolve_users(args, _) do
    Relay.Connection.from_query(User, &Repo.all/1, args)
  end

  @doc """
  Resolves a user creation.
  """
  def resolve_create_user(args, _) do
  end
end
