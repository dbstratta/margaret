defmodule MargaretWeb.Context do
  @moduledoc """
  Build the GraphQL context.
  """

  @behaviour Plug

  alias Margaret.Accounts.User

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _) do
    conn
    |> Guardian.Plug.current_resource()
    |> build_context(conn)
  end

  defp build_context(%User{} = viewer, conn) do
    Absinthe.Plug.put_options(conn, context: %{viewer: viewer})
  end

  defp build_context(nil, conn) do
    Absinthe.Plug.put_options(conn, context: %{})
  end
end
