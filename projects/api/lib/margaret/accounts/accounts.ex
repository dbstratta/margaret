defmodule Margaret.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query

  alias Margaret.Repo
  alias Margaret.Accounts.{User, SocialLogin}

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  @spec get_user(String.t) :: User.t
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(String.t) :: User.t
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a user by its username.

  ## Examples

      iex> get_user_by_username("user123")
      %User{}

      iex> get_user_by_username("user456")
      nil

  """
  @spec get_user_by_username(String.t) :: User.t
  def get_user_by_username(username), do: Repo.get_by(User, username: username)

  @doc """
  Gets a user by its username.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_username!("user123")
      %User{}

      iex> get_user_by_username!("user456")
      ** (Ecto.NoResultsError)

  """
  @spec get_user_by_username!(String.t) :: User.t
  def get_user_by_username!(username), do: Repo.get_by!(User, username: username)

  @doc """
  Gets a user by its social login.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_social_login!(:facebook, 123)
      %User{}

      iex> get_user_by_social_login!(:google, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user_by_social_login!(atom, String.t) :: User.t
  def get_user_by_social_login!(provider, uid) do
    Repo.get_by!(SocialLogin, [provider: provider, uid: uid])
  end

  @doc """
  Creates a new user.
  """
  @spec create_user(%{optional(any) => any}) :: Ecto.Changeset
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
