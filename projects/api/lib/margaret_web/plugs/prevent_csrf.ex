defmodule MargaretWeb.Plugs.PreventCSRF do
  @moduledoc """
  Plug that checks for the HTTP header `X-Requested-With` in POST requests.
  It prevents CSRF attacks.
  """

  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{method: "POST"} = conn, _) do
    is_custom_header = fn {header_name, _} -> header_name === "x-requested-with" end

    case Enum.any?(conn.req_headers, is_custom_header) do
      true -> conn
      _ -> send_resp(conn, 403, "Forbidden")
    end
  end

  def call(conn, _) do
    conn
  end
end
