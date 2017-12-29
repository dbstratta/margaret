defmodule Margaret.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query

  alias Margaret.Repo
  alias Margaret.Accounts.{User, SocialLogin, Follow}

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  @spec get_user(String.t) :: User.t | nil
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
  Gets a user by its email.

  ## Examples

      iex> get_user_by_email("user@example.com")
      %User{}

      iex> get_user_by_email("user@example.com")
      nil

  """
  @spec get_user_by_email(String.t) :: User.t
  def get_user_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Gets a user by its email.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_email!("user@example.com")
      %User{}

      iex> get_user_by_email!("user@example.com")
      ** (Ecto.NoResultsError)

  """
  @spec get_user_by_email!(String.t) :: User.t
  def get_user_by_email!(email), do: Repo.get_by!(User, email: email)

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
    SocialLogin
    |> Repo.get_by!([provider: provider, uid: uid])
    |> Repo.preload(:user)
    |> Map.get(:user)
  end

  @doc """
  Creates a user.

  ## Examples

    iex> create_user(attrs)
    {:ok, %User{}}

    iex> create_user(%{field: bad_value})
    {:error, %Ecto.Changeset{}}

  """
  @spec create_user(%{optional(any) => any}) :: {atom, Ecto.Changeset}
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Inserts a social login.

  ## Examples

    iex> insert_social_login(attrs)
    {:ok, %SocialLogin{}}

    iex> insert_social_login(%{field: bad_value})
    {:error, %Ecto.Changeset{}}

  """
  @spec insert_social_login(%{optional(any) => any}) :: {atom, Ecto.Changeset}
  def insert_social_login(attrs) do
    %SocialLogin{}
    |> SocialLogin.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Inserts a social login.

  ## Examples

    iex> insert_social_login(attrs)
    {:ok, %SocialLogin{}}

    iex> insert_social_login(bad_attrs)
    {:error, %Ecto.Changeset{}}

  """
  def insert_social_login!(attrs) do
    %SocialLogin{}
    |> SocialLogin.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Gets a follow.

  ## Examples

      iex> get_follow(123)
      %Follow{}

      iex> get_follow(456)
      nil

      iex> get_follow(follower_id: 123, user_id: 234)
      %Follow{}

      iex> get_follow(follower_id: 123, publication_id: 234)
      nil

  """
  @spec get_follow(term) :: Follow.t | nil
  def get_follow(id) when is_integer(id) or is_binary(id), do: Repo.get(Follow, id)

  @spec get_follow([{atom, term}]) :: Follow.t | nil
  def get_follow(follower_id: follower_id, user_id: user_id) do
    Repo.get_by(Follow, follower_id: follower_id, user_id: user_id)
  end

  def get_follow(follower_id: follower_id, publication_id: publication_id) do
    Repo.get_by(Follow, follower_id: follower_id, publication_id: publication_id)
  end

  @doc """
  Inserts a follow.
  """
  def insert_follow(%{follower_id: follower_id} = attrs) when is_binary(follower_id) do
    attrs
    |> Map.update(:follower_id, nil, &String.to_integer(&1))
    |> insert_follow()
  end

  def insert_follow(%{follower_id: follower_id, user_id: user_id}) when follower_id === user_id do
    {:error, "You can't follow yourself."}
  end

  def insert_follow(attrs) do
    %Follow{}
    |> Follow.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a follow.
  """
  def delete_follow(id) when is_integer(id) or is_binary(id) do

  end
end
