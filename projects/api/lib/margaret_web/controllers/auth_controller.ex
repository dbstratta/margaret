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
  def request(conn, _params), do: send_resp(conn, 400, "")

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    send_resp(conn, 500, "")
  end

  def callback(%{assigns: %{ueberauth_auth: %{provider: provider, uid: uid}}} = conn, _params) do
    token = get_token(conn, to_string(provider), to_string(uid))

    json(conn, %{token: token})
  end

  # TODO: Refactor!
  @spec get_token(%Plug.Conn{} | String.t(), String.t(), String.t()) :: Guardian.Token.token()
  defp get_token(%Plug.Conn{} = conn, provider, uid) do
    %{"email" => email} = conn.assigns.ueberauth_auth.extra.raw_info.user

    try do
      {:ok, token, _} =
        {provider, uid}
        |> Accounts.get_user_by_social_login!(include_deactivated: true)
        |> Accounts.activate_user!()
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
        %User{} = user -> {:ok, Accounts.activate_user(user)}
        nil -> Accounts.insert_user(%{username: UUID.uuid4(), email: email})
      end

    user
  end

  @doc """
  Refreshes a JWT token.
  """
  def refresh(conn, %{token: token}) do
    token
    |> MargaretWeb.Guardian.refresh()
    |> do_refresh(conn)
  end

  defp do_refresh({:ok, _old, {new_token, _new_claims}}, conn),
    do: json(conn, %{token: new_token})

  defp do_refresh({:error, reason}, conn), do: send_resp(conn, 401, reason)
end
