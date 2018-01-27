defmodule MargaretWeb.AuthPipeline do
  @moduledoc """
  Authentication pipeline.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :margaret,
    module: MargaretWeb.Guardian,
    error_handler: __MODULE__

  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.LoadResource, allow_blank: true)

  def auth_error(conn, {type, reason}, _opts) do
    body = Poison.encode!(%{error: %{type: to_string(type), reason: to_string(reason)}})
    send_resp(conn, 401, body)
  end
end
