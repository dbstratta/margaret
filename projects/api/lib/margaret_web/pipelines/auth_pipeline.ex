defmodule MargaretWeb.AuthPipeline do
  @moduledoc """
  Authentication pipeline.
  """

  use Guardian.Plug.Pipeline,
    otp_app: :margaret,
    module: MargaretWeb.Guardian

  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
