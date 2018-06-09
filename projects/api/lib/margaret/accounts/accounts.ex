defmodule Margaret.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query

  alias Margaret.{
    Repo,
    Accounts,
    Helpers
  }

  alias Accounts.User

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  @spec get_user(String.t() | non_neg_integer(), Keyword.t()) :: User.t() | nil
  def get_user(id, opts \\ []) do
    User
    |> maybe_include_deactivated(opts)
    |> Repo.get(id)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user!(String.t() | non_neg_integer, Keyword.t()) :: User.t() | no_return()
  def get_user!(id, opts \\ []) do
    User
    |> maybe_include_deactivated(opts)
    |> Repo.get!(id)
  end

  @doc """
  Gets a user by its username.

  ## Examples

      iex> get_user_by_username("user123")
      %User{}

      iex> get_user_by_username("user456")
      nil

  """
  @spec get_user_by_username(String.t(), Keyword.t()) :: User.t() | nil
  def get_user_by_username(username, opts \\ []), do: get_user_by([username: username], opts)

  @doc """
  Gets a user by its username.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_username!("user123")
      %User{}

      iex> get_user_by_username!("user456")
      ** (Ecto.NoResultsError)

  """
  @spec get_user_by_username!(String.t(), Keyword.t()) :: User.t() | no_return()
  def get_user_by_username!(username, opts \\ []), do: get_user_by!([username: username], opts)

  @doc """
  Gets a user by its email.

  ## Examples

      iex> get_user_by_email("user@example.com")
      %User{}

      iex> get_user_by_email("user@example.com")
      nil

  """
  @spec get_user_by_email(String.t(), Keyword.t()) :: User.t() | nil
  def get_user_by_email(email, opts \\ []), do: get_user_by([email: email], opts)

  @doc """
  Gets a user by its email.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_email!("user@example.com")
      %User{}

      iex> get_user_by_email!("user@example.com")
      ** (Ecto.NoResultsError)

  """
  @spec get_user_by_email!(String.t(), Keyword.t()) :: User.t() | no_return()
  def get_user_by_email!(email, opts \\ []), do: get_user_by!([email: email], opts)

  @doc """
  Gets a user by given clauses.
  """
  @spec get_user_by(Keyword.t(), Keyword.t()) :: User.t() | nil
  def get_user_by(clauses, opts \\ []) do
    User
    |> maybe_include_deactivated(opts)
    |> Repo.get_by(clauses)
  end

  @spec get_user_by!(Keyword.t(), Keyword.t()) :: User.t() | no_return()
  def get_user_by!(clauses, opts \\ []) do
    User
    |> maybe_include_deactivated(opts)
    |> Repo.get_by!(clauses)
  end

  @spec maybe_include_deactivated(Ecto.Queryable.t(), Keyword.t()) :: Ecto.Queryable.t()
  defp maybe_include_deactivated(query, opts) do
    case Keyword.get(opts, :include_deactivated, false) do
      true -> query
      false -> from(u in query, where: is_nil(u.deactivated_at))
    end
  end

  def admin?(%User{is_admin: true}), do: true
  def admin?(_user), do: false

  def active?(%User{deactivated_at: nil}), do: true
  def active?(_user), do: false

  @spec member?(User.t()) :: boolean()
  def member?(%User{}), do: false

  @doc """
  Returns `true` if the user has enabled notifications for
  when one of their stories is starred.

  ## Examples

      iex> starred_story_notifications_enabled(%User{})
      true

  """
  @spec starred_story_notifications_enabled?(User.t()) :: boolean()
  def starred_story_notifications_enabled?(%User{settings: settings}) do
    settings.notifications.starred_story
  end

  @doc """
  Inserts a user.

  ## Examples

      iex> insert_user(attrs)
      {:ok, %User{}}

      iex> insert_user(bad_attrs)
      {:error, %Ecto.Changeset{}}

  """
  @spec insert_user(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def insert_user(attrs) do
    attrs
    |> User.changeset()
    |> Repo.insert()
  end

  @doc """
  Returns `true` if the username is available to use.
  `false` otherwise.
  """
  @spec available_username?(String.t()) :: boolean()
  def available_username?(username) do
    %{username: username, active_only: false}
    |> Accounts.Queries.users()
    |> Repo.exists?()
  end

  @doc """
  Returns `true` if the username is eligible to use.
  `false` otherwise.

  For a username to be eligible it has to be available and have a valid format.
  """
  @spec eligible_username?(String.t()) :: boolean()
  def eligible_username?(username),
    do: User.valid_username?(username) and available_username?(username)

  @doc """
  Returns `true` if the email is available to use.
  `false` otherwise.
  """
  @spec available_email?(String.t()) :: boolean()
  def available_email?(email) do
    %{email: email, active_only: false}
    |> Accounts.Queries.users()
    |> Repo.exists?()
  end

  @doc """
  Updates a user.
  """
  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Verifies the email of a user with a unverified email.
  """
  @spec verify_email(User.t()) :: {:ok, User.t()} | any()
  def verify_email(%User{unverified_email: email} = user) when not is_nil(email) do
    attrs = %{email: email, unverified_email: nil}
    update_user(user, attrs)
  end

  @doc """
  Activates a user.

  If the user was not deactivated it doesn't do anything.
  """
  @spec activate_user(User.t()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def activate_user(%User{} = user) do
    attrs = %{deactivated_at: nil}
    update_user(user, attrs)
  end

  @doc """
  Deletes a user.
  """
  @spec delete_user(User.t()) :: User.t()
  def delete_user(%User{} = user), do: Repo.delete!(user)

  @doc """
  """
  @spec users(map()) :: any()
  def users(args) do
    args
    |> Accounts.Queries.users()
    |> Helpers.Connection.from_query(args)
  end

  @doc """
  Returns the user count.

  ## Examples

      iex> user_count()
      1000

      iex> user_count(%{active_only: false})
      2000

  """
  @spec user_count(map()) :: non_neg_integer()
  def user_count(args) do
    args
    |> Accounts.Queries.users()
    |> Repo.count()
  end
end
