defmodule MargaretWeb.Context do
  @moduledoc """
  Build the GraphQL context.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    case Guardian.Plug.current_resource(conn) do
      nil -> put_private(conn, :absinthe, %{context: %{user: nil}})
      user -> put_private(conn, :absinthe, %{context: %{user: user}})
    end
  end
end
