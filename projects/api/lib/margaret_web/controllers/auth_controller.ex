defmodule MargaretWeb.AuthController do
  use MargaretWeb, :controller

  alias Margaret.Accounts.User

  plug Ueberauth

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    nil
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    nil
  end
end
