defmodule Margaret.SocialLogins do
  @moduledoc """
  The Social Logins context.
  """

  import Ecto.Query

  alias Margaret.{
    Repo,
    Accounts,
    SocialLogins
  }

  alias Accounts.User
  alias SocialLogins.SocialLogin

  @typedoc """
  The tuple of `provider` and `uid` from an OAuth2 provider.
  """
  @type social_credentials :: {
          provider :: String.t(),
          uid :: String.t()
        }

  @doc """
  Gets a user by its social login.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_social_login!({"facebook", 123})
      %User{}

      iex> get_user_by_social_login!({"google", 456}, active_only: true)
      ** (Ecto.NoResultsError)

  """
  @spec get_user_by_social_credentials!(social_credentials(), Keyword.t()) ::
          User.t() | no_return()
  def get_user_by_social_credentials!({provider, uid}, opts \\ []) do
    active_users_only = Keyword.get(opts, :active_only, false)
    users_query = Accounts.Queries.users(%{active_only: active_users_only})

    query =
      from u in users_query,
        join: sl in assoc(u, :social_logins),
        where: sl.provider == ^provider and sl.uid == ^uid

    Repo.one!(query)
  end

  @spec insert_social_login(map()) :: {:error, Ecto.Changeset.t()} | {:ok, SocialLogin.t()}
  defp insert_social_login(attrs) do
    attrs
    |> SocialLogin.changeset()
    |> Repo.insert()
  end

  @doc """
  Links a social credentials to a user.
  """
  @spec link_social_credentials_to_user(User.t(), social_credentials()) ::
          {:ok, SocialLogin.t()} | {:error, Ecto.Changeset.t()}
  def link_social_credentials_to_user(%User{id: user_id}, {provider, uid}) do
    attrs = %{user_id: user_id, provider: provider, uid: uid}
    insert_social_login(attrs)
  end

  @spec social_logins(User.t()) :: [SocialLogin.t()]
  def social_logins(%User{} = user) do
    user
    |> Repo.preload(:social_logins)
    |> Map.fetch!(:social_logins)
  end
end
