defmodule MargaretWeb.Middleware.RequireAuthenticated do
  @moduledoc """
  Absinthe middleware to only permit actions when
  the user is authenticated.

  If no option is given, it'll resolve an error.
  If `resolve: value` is given, it'll resolve `{:ok, value}`.

  ## Examples

  ```elixir
  middleware MargaretWeb.Middleware.RequireAuthenticated
  resolve &resolver/2

  middleware MargaretWeb.Middleware.RequireAuthenticated, resolve: nil
  resolve &resolver/2

  middleware MargaretWeb.Middleware.RequireAuthenticated, resolve: false
  resolve &resolver/2
  ```

  """

  @behaviour Absinthe.Middleware

  import Absinthe.Resolution, only: [put_result: 2]

  alias Margaret.Accounts.User
  alias MargaretWeb.Helpers

  @doc false
  @impl true
  def call(%Absinthe.Resolution{context: %{viewer: %User{}}} = resolution, _), do: resolution
  def call(resolution, resolve: value), do: put_result(resolution, {:ok, value})
  def call(resolution, _), do: put_result(resolution, Helpers.GraphQLErrors.unauthorized())
end
