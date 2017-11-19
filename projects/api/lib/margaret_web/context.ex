defmodule MargaretWeb.Context do
  @behaviour Plug

  import Plug.Conn
  import Ecto.Query, only: [first: 1]

  def init(opts), do: opts

  def call(conn, _default) do
    nil
  end
end
