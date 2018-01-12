defmodule MargaretWeb.Middleware.RequireActive do
  @moduledoc """
  Absinthe middleware to only permit actions when
  the user is active.

  ## Examples

  ```elixir
  middleware MargaretWeb.Middleware.RequireActive
  resolve &resolver/2
  ```
  
  """

  @behaviour Absinthe.Middleware

  import Absinthe.Resolution, only: [put_result: 2]

  alias Margaret.Accounts.User
  alias MargaretWeb.Helpers

  @doc false
  @impl true
  def call(%Absinthe.Resolution{context: %{viewer: %User{deactivated_at: nil}}} = resolution, _) do
    resolution
  end

  def call(resolution, _), do: put_result(resolution, Helpers.GraphQLErrors.deactivated())
end