defmodule MargaretWeb.Context do
  @moduledoc """
  Build the GraphQL context.
  """

  @behaviour Plug

  import Plug.Conn

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
    put_private(conn, :absinthe, %{context: %{viewer: viewer}})
  end

  defp build_context(nil, conn) do
    put_private(conn, :absinthe, %{context: %{}})
  end
end
