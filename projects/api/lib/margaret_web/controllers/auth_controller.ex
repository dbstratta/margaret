defmodule MargaretWeb.AuthController do
  @moduledoc """
  The Authentication controller.

  Here we handle OAuth2 callbacks and JWT operations
  related to authentication.
  """

  use MargaretWeb, :controller

  alias Margaret.{Accounts, UserRegistration}

  plug Ueberauth

  @doc """
  We don't need this function, but we need it to reference it in the router.
  The Ueberauth strategies intercept the connection before it reaches this action
  and redirect to the Authorization Server.
  """
  def request(conn, _params), do: send_resp(conn, 400, "")

  @doc """
  Callback handler for OAuth2 redirects.
  """
  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    # If something failed on their side we can't do anything.
    send_resp(conn, 500, "")
  end

  def callback(conn, _params) do
    attrs = extract_attrs_from_provided_info(conn)
    social_credentials = extract_social_credentials_from_provided_info(conn)

    {:ok, user} =
      social_credentials
      |> UserRegistration.get_user_by_social_credentials_or_register_user!(attrs)
      |> Accounts.activate_user()

    token = MargaretWeb.Guardian.encode_and_sign(user)
    response = %{token: token}

    json(conn, response)
  end

  @spec extract_attrs_from_provided_info(Plug.Conn.t()) :: map()
  defp extract_attrs_from_provided_info(%Plug.Conn{} = conn) do
    %{
      email: conn.assigns.ueberauth_auth.extra.raw_info.user.email
    }
  end

  @spec extract_social_credentials_from_provided_info(Plug.Conn.t()) ::
          SocialLogins.social_credentials()
  defp extract_social_credentials_from_provided_info(conn) do
    %{provider: provider, uid: uid} = conn.assigns.ueberauth_auth

    {to_string(provider), to_string(uid)}
  end

  @doc """
  Refreshes a JWT token.
  """
  def refresh(conn, %{token: token}) do
    token
    |> MargaretWeb.Guardian.refresh()
    |> case do
      {:ok, _old, {new_token, _new_claims}} ->
        response = %{token: new_token}
        json(conn, response)

      {:error, reason} ->
        send_resp(conn, 401, reason)
    end
  end
end
