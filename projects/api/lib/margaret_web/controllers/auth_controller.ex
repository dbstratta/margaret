defmodule MargaretWeb.AuthController do
  @moduledoc """
  The Authentication controller.
  """

  use MargaretWeb, :controller

  alias Margaret.Accounts
  alias Accounts.User

  plug(Ueberauth)

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

  @spec get_token(%Plug.Conn{} | String.t(), String.t(), String.t()) :: Guardian.Token.token()
  defp get_token(%Plug.Conn{} = conn, provider, uid) do
    %{"email" => email} = conn.assigns.ueberauth_auth.extra.raw_info.user

    try do
      {:ok, token, _} =
        {provider, uid}
        |> Accounts.get_user_by_social_login!(include_deactivated: true)
        |> activate_user()
        |> MargaretWeb.Guardian.encode_and_sign()

      token
    rescue
      _ -> get_token(email, provider, uid)
    end
  end

  defp get_token(email, provider, uid) when is_binary(email) do
    user = get_or_create_user(email)

    Accounts.insert_social_login!(%{provider: provider, uid: uid, user_id: user.id})

    {:ok, token, _} = MargaretWeb.Guardian.encode_and_sign(user)

    token
  end

  @spec get_or_create_user(String.t()) :: User.t()
  defp get_or_create_user(email) do
    {:ok, user} =
      case Accounts.get_user_by_email(email, include_deactivated: true) do
        %User{} = user -> {:ok, activate_user(user)}
        nil -> Accounts.insert_user(%{username: UUID.uuid4(), email: email})
      end

    user
  end

  defp activate_user(%User{deactivated_at: deactivated_at} = user) when not is_nil(deactivated_at) do
    {:ok, user} = Accounts.update_user(user, %{deactivated_at: nil})

    user
  end

  defp activate_user(user), do: user
end
