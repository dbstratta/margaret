defmodule MargaretWeb.AuthController do
  use MargaretWeb, :controller

  alias Margaret.Accounts.User

  plug Ueberauth

  def request(conn, _params), do: nil

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
  end

  def callback(%{assigns: %{ueberauth_auth: %{provider: provider}}} = conn, _params) do
    do_callback(conn, provider)
  end

  defp do_callback(%{assigns: %{ueberauth_auth: %{uid: uid}}} = conn, :facebook) do
    sign_up_or_sign_in_user(conn, :facebook, uid)
  end

  defp sign_up_or_sign_in_user(conn, provider, uid) do
    try do
      sign_in_user(conn)
    catch
      _ -> sign_up_user(conn)
    end
  end

  defp sign_up_user(conn) do

  end

  defp sign_in_user(conn) do

  end
end
