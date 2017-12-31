defmodule MargaretWeb.Middleware.Authenticated do
  @moduledoc """
  Absinthe middleware to only permit actions when
  the user is authenticated.

  If no option is given, it'll resolve an error.
  If `resolve_nil` is true, it'll resolve `{:ok, nil}`

  ## Examples

    middleware MargaretWeb.Middleware.Authenticated
    resolve &resolver/2

    middleware MargaretWeb.Middleware.Authenticated, resolve_nil: true
    resolve &resolver/2
  
  """

  @behaviour Absinthe.Middleware

  import Absinthe.Resolution, only: [put_result: 2]

  alias Margaret.Accounts.User
  alias MargaretWeb.Helpers

  @doc false
  @impl true
  def call(%Absinthe.Resolution{context: %{viewer: %User{}}} = resolution, _), do: resolution

  def call(resolution, resolve_nil: true), do: put_result(resolution, {:ok, nil})

  def call(resolution, _) do
    put_result(resolution, Helpers.GraphQLErrors.unauthorized())
  end
end