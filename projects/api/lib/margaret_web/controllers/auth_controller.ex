defmodule MargaretWeb.AuthController do
  use MargaretWeb, :controller

  alias Margaret.Accounts.User

  plug Ueberauth

  def request(conn, _params), do: nil

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    IO.inspect fails
    conn
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    do_callback(conn, provider)
  end

  defp do_callback(%{assigns: %{ueberauth_auth: %{uid: uid}}} = conn, :facebook) do
    sign_up_or_sign_in_user(conn, :facebook, uid)
  end

  defp sign_up_or_sign_in_user(conn, :facebook, uid) do
    conn
  end
end
