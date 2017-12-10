defmodule MargaretWeb.AuthController do
  @moduledoc """
  The Authentication controller.
  """

  use MargaretWeb, :controller

  alias Margaret.Accounts
  alias Accounts.User

  plug Ueberauth

  @doc """
  We don't need this function, but we need it to reference it in the router.
  The Ueberauth strategies intercept the connection before it reaches this action
  and redirect to the Authorization Server.
  """
  def request(_conn, _params), do: nil

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
  end

  def callback(%{assigns: %{ueberauth_auth: %{provider: provider, uid: uid}}} = conn, _params) do
    json(conn, %{token: get_token(conn, to_string(provider), to_string(uid))})
  end

  @spec get_token(%Plug.Conn{} | String.t, String.t, String.t) :: Guardian.Token.token
  defp get_token(%Plug.Conn{} = conn, provider, uid) do
    %{"email" => email} = conn.assigns.ueberauth_auth.extra.raw_info.user

    try do
      user = Accounts.get_user_by_social_login!(provider, uid)
      {:ok, token, _} = MargaretWeb.Guardian.encode_and_sign(user)
      token
    rescue
      _ -> get_token(email, provider, uid)
    end
  end

  defp get_token(email, provider, uid) when is_binary(email) do
    user = get_or_create_user(email)

    Accounts.create_social_login!(%{provider: provider, uid: uid, user_id: user.id})

    {:ok, token, _} = MargaretWeb.Guardian.encode_and_sign(user)
    token
  end

  @spec get_or_create_user(String.t) :: {:ok, User.t}
  defp get_or_create_user(email) do
    {:ok, user} =
      case Accounts.get_user_by_email(email) do
        nil -> Accounts.create_user(%{username: UUID.uuid4(), email: email})
        user -> {:ok, user}
      end

    user
  end
end
