defmodule Margaret.UserRegistration do
  @moduledoc """
  The User Registration context.
  """

  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    SocialLogins
  }

  alias Accounts.User

  @doc """
  """
  @spec get_user_by_social_credentials_or_register_user!(
          SocialLogins.social_credentials(),
          map()
        ) :: User.t()
  def get_user_by_social_credentials_or_register_user!(social_credentials, attrs) do
    SocialLogins.get_user_by_social_credentials!(social_credentials)
  rescue
    _ -> get_user_by_email_or_register_user!(social_credentials, attrs)
  end

  @spec get_user_by_email_or_register_user!(SocialLogins.social_credentials(), map()) :: User.t()
  defp get_user_by_email_or_register_user!(social_credentials, attrs) do
    attrs
    |> Map.fetch!(:email)
    |> Accounts.get_user_by_email!()
  rescue
    _ -> register_user!(social_credentials, attrs)
  end

  @spec register_user!(SocialLogins.social_credentials(), map()) :: User.t()
  def register_user!(social_credentials, attrs) do
    attrs = maybe_put_username(attrs)

    {:ok, %{user: user}} =
      Multi.new()
      |> insert_user(attrs)
      |> link_social_credentials_to_user(social_credentials)
      |> Repo.transaction()

    user
  end

  @spec maybe_put_username(map()) :: map()
  defp maybe_put_username(%{username: username} = attrs) when not is_nil(username), do: attrs

  defp maybe_put_username(%{email: email} = attrs) do
    username = extract_or_generate_username(email)
    Map.put_new(attrs, :username, username)
  end

  @spec extract_or_generate_username(String.t()) :: String.t()
  defp extract_or_generate_username(email) do
    username = extract_username_from_email(email)

    if Accounts.eligible_username?(username) do
      username
    else
      UUID.uuid4()
    end
  end

  @spec extract_username_from_email(String.t()) :: String.t()
  defp extract_username_from_email(email) do
    email
    |> String.split("@")
    |> List.first()
  end

  @spec insert_user(Multi.t(), map()) :: Multi.t()
  defp insert_user(multi, attrs) do
    insert_user_fn = fn _ ->
      Accounts.insert_user(attrs)
    end

    Multi.run(multi, :user, insert_user_fn)
  end

  @spec link_social_credentials_to_user(Multi.t(), SocialLogins.social_credentials()) :: Multi.t()
  defp link_social_credentials_to_user(multi, social_credentials) do
    link_social_credentials_to_user_fn = fn %{user: user} ->
      SocialLogins.link_social_credentials_to_user(user, social_credentials)
    end

    Multi.run(multi, :social_login, link_social_credentials_to_user_fn)
  end
end
