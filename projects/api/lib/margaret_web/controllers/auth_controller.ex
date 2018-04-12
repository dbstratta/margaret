defmodule MargaretWeb.AuthController do
  @moduledoc """
  The Authentication controller.
  """

  use MargaretWeb, :controller

  alias Margaret.Accounts

  plug(Ueberauth)

  @doc """
  We don't need this function, but we need it to reference it in the router.
  The Ueberauth strategies intercept the connection before it reaches this action
  and redirect to the Authorization Server.
  """
  def request(conn, _params), do: send_resp(conn, 400, "")

  @spec get_email_from_provided_info(Plug.Conn.t()) :: String.t()
  defp get_email_from_provided_info(%Plug.Conn{} = conn) do
    conn.assigns.ueberauth_auth.extra.raw_info.user.email
  end

  @spec get_attrs_from_provided_info(Plug.Conn.t()) :: map()
  defp get_attrs_from_provided_info(%Plug.Conn{} = _conn) do
    %{}
  end

  @doc """
  Callback handler for OAuth2 redirects.
  """
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    # If something failed on their side we can't do anything.
    send_resp(conn, 500, "")
  end

  def callback(%{assigns: %{ueberauth_auth: %{provider: provider, uid: uid}}} = conn, _params) do
    email = get_email_from_provided_info(conn)
    attrs = get_attrs_from_provided_info(conn)

    social_credentials = {to_string(provider), to_string(uid)}

    token = get_token(email, social_credentials, attrs)

    json(conn, %{token: token})
  end

  @spec get_token(String.t(), Accounts.social_credentials(), map()) :: Guardian.Token.token()
  defp get_token(email, social_credentials, attrs) do
    get_user_and_get_token!(social_credentials)
  rescue
    _ -> insert_user_and_get_token!(email, social_credentials, attrs)
  end

  defp get_user_and_get_token!(social_credentials) do
    {:ok, token, _} =
      social_credentials
      |> Accounts.get_user_by_social_login!(include_deactivated: true)
      |> Accounts.activate_user!()
      |> MargaretWeb.Guardian.encode_and_sign()

    token
  end

  @spec insert_user_and_get_token!(String.t(), Accounts.social_credentials(), map()) ::
          Guardian.Token.token() | no_return()
  defp insert_user_and_get_token!(email, social_credentials, attrs) do
    user =
      email
      |> Accounts.get_or_insert_user!(attrs)
      |> Accounts.activate_user!()

    Accounts.link_social_login_to_user!(user, social_credentials)

    {:ok, token, _} = MargaretWeb.Guardian.encode_and_sign(user)

    token
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
