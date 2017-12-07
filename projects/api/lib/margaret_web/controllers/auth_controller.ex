defmodule MargaretWeb.AuthController do
  @moduledoc """
  The Authentication controller.
  """

  use MargaretWeb, :controller

  alias Margaret.Accounts
  alias Accounts.User

  plug Ueberauth

  def request(conn, _params), do: nil

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
  end

  def callback(%{assigns: %{ueberauth_auth: %{provider: provider}}} = conn, _params) do
    do_callback(conn, provider)
  end

  defp do_callback(%{assigns: %{ueberauth_auth: %{uid: uid}}} = conn, :facebook) do
    sign_in_user(conn, :facebook, uid)
  end

  defp sign_in_user(conn, provider, uid) do
    try do
      user = Accounts.get_user_by_social_login!(provider, uid)
      {:ok, token, _} = MargaretWeb.Guardian.encode_and_sign(user)
      token
    catch
      _ -> sign_up_user(conn, provider, uid)
    end
  end

  defp sign_up_user(conn, provider, uid) do

  end
end
