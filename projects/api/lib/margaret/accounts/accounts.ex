defmodule Margaret.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Publications,
    Stories,
    Follows
  }

  alias Accounts.{User, SocialLogin}
  alias Stories.Story
  alias Publications.PublicationMembership

  @typedoc """
  The tuple of `provider` and `uid` from an OAuth2 provider.
  """
  @type social_credentials :: {provider :: String.t(), uid :: String.t()}

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  @spec get_user(String.t() | non_neg_integer, Keyword.t()) :: User.t() | nil
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
  @spec get_user!(String.t() | non_neg_integer, Keyword.t()) :: User.t() | no_return
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
  @spec get_user_by_username!(String.t(), Keyword.t()) :: User.t() | no_return
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
  @spec get_user_by_email!(String.t(), Keyword.t()) :: User.t() | no_return
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

  def get_user_by!(clauses, opts \\ []) do
    User
    |> maybe_include_deactivated(opts)
    |> Repo.get_by!(clauses)
  end

  @doc """
  Gets a user by its social login.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_social_login!(:facebook, 123)
      %User{}

      iex> get_user_by_social_login!(:google, 456)
      ** (Ecto.NoResultsError)

  """
  @spec get_user_by_social_login!({atom, String.t()}) :: User.t() | no_return
  def get_user_by_social_login!({provider, uid}, opts \\ []) do
    User
    |> maybe_include_deactivated(opts)
    |> join(:inner, [u], sl in assoc(u, :social_logins))
    |> where([..., sl], sl.provider == ^provider and sl.uid == ^uid)
    |> Repo.one!()
  end

  @doc """
  Gets the user count.

  ## Examples

      iex> get_user_count()
      42

  """
  @spec get_user_count :: non_neg_integer
  def get_user_count(opts \\ []) do
    User
    |> maybe_include_deactivated(opts)
    |> Repo.aggregate(:count, :id)
  end

  defp maybe_include_deactivated(query, opts) do
    opts
    |> Keyword.get(:include_deactivated, false)
    |> do_maybe_include_deactivated(query)
  end

  defp do_maybe_include_deactivated(false, query), do: User.active(query)
  defp do_maybe_include_deactivated(true, query), do: query

  def member?(%User{}), do: false

  @doc """
  Inserts a user.
  TODO: Refactor to use Ecto.Multi and send email when creating user.

  ## Examples

      iex> insert_user(attrs)
      {:ok, %User{}}

      iex> insert_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec insert_user(%{optional(any) => any}) :: {:error, Ecto.Changeset.t()} | {:ok, User.t()}
  def insert_user(attrs) do
    attrs
    |> User.changeset()
    |> Repo.insert()
  end

  @doc """
  Inserts a user.

  Raises `Ecto.InvalidChangesetError` if the attributes are invalid.

  ## Examples

      iex> insert_user!(attrs)
      %User{}

      iex> insert_user!(bad_attrs)
      ** (Ecto.InvalidChangesetError)

  """
  @spec insert_user!(%{optional(any) => any}) :: User.t() | no_return
  def insert_user!(attrs) do
    attrs
    |> User.changeset()
    |> Repo.insert!()
  end

  @doc """
  Gets or inserts a user by given email.

  If there's a user with that email, return it.
  Otherwise, insert a user with that email.

  When inserting the user, we try to set its username
  to the part before the `@` in the email.
  If it's already taken we take a UUID.

  TODO: Accept more attrs when inserting.
  """
  @spec get_or_insert_user(String.t()) :: User.t()
  def get_or_insert_user(email) do
    email
    |> get_user_by_email(include_deactivated: true)
    |> do_get_or_insert_user(email)
  end

  defp do_get_or_insert_user(%User{} = user, _email), do: {:ok, user}

  defp do_get_or_insert_user(nil, email) do
    [username | _] = String.split(email, "@")

    username = if eligible_username?(username), do: username, else: UUID.uuid4()

    attrs = %{username: username, email: email}

    insert_user(attrs)
  end

  def get_or_insert_user!(email) do
    case get_or_insert_user(email) do
      {:ok, user} ->
        user

      {:error, reason} ->
        raise """
        cannot get or insert user.
        Reason: #{inspect(reason)}
        """
    end
  end

  @doc """
  Returns `true` if the username is available to use.
  `false` otherwise.
  """
  @spec available_username?(String.t()) :: boolean
  def available_username?(username),
    do: !get_user_by_username(username, include_deactivated: true)

  @doc """
  Returns `true` if the username is eligible to use.
  `false` otherwise.

  For a username to be eligible it has to be available and have a valid format.
  """
  @spec eligible_username?(String.t()) :: boolean
  def eligible_username?(username),
    do: available_username?(username) and User.valid_username?(username)

  @doc """
  Returns `true` if the email is available to use.
  `false` otherwise.
  """
  @spec available_email?(String.t()) :: boolean
  def available_email?(email), do: !get_user_by_email(email, include_deactivated: true)

  @doc """
  Updates a user.
  """
  @spec update_user(User.t(), any) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Activates a user.

  If the user was not deactivated it doesn't
  do anything.
  """
  def activate_user(%User{deactivated_at: nil} = user), do: {:ok, user}

  def activate_user(%User{} = user) do
    update_user(user, %{deactivated_at: nil})
  end

  @doc """
  Activates a user.
  """
  def activate_user!(%User{} = user) do
    case activate_user(user) do
      {:ok, user} ->
        user

      {:error, reason} ->
        raise """
        cannot activate user.
        Reason: #{inspect(reason)}
        """
    end
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user), do: Repo.delete(user)

  @doc """
  Deletes a user.
  """
  def delete_user!(%User{} = user), do: Repo.delete!(user)

  @doc """
  Marks a user for deletion.

  Enqueues a task that deletes the account and all its content
  after the specified time has passed.
  """
  def mark_user_for_deletion(%User{id: user_id} = user) do
    user_changeset = User.update_changeset(user, %{})

    # 15 days.
    seconds_before_deletion = 60 * 60 * 24 * 15

    schedule_deletion = fn _ ->
      Exq.enqueue_in(
        Exq,
        "user_deletion",
        seconds_before_deletion,
        Margaret.Workers.DeleteAccount,
        [user_id]
      )
    end

    Multi.new()
    |> Multi.update(:deactivate_user, user_changeset)
    |> Multi.run(:schedule_deletion, schedule_deletion)
    |> Repo.transaction()
  end

  @doc """
  Inserts a social login.

  ## Examples

      iex> insert_social_login(attrs)
      {:ok, %SocialLogin{}}

      iex> insert_social_login(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec insert_social_login(%{optional(any) => any}) ::
          {:error, Ecto.Changeset.t()} | {:ok, SocialLogin.t()}
  def insert_social_login(attrs) do
    attrs
    |> SocialLogin.changeset()
    |> Repo.insert()
  end

  @doc """
  Inserts a social login.

  Raises `Ecto.InvalidChangesetError` if the attributes are invalid.

  ## Examples

      iex> insert_social_login!(attrs)
      {:ok, %SocialLogin{}}

      iex> insert_social_login!(bad_attrs)
      ** (Ecto.InvalidChangesetError)

  """
  def insert_social_login!(attrs) do
    attrs
    |> SocialLogin.changeset()
    |> Repo.insert!()
  end

  @doc """
  Links a user to a social account.
  """
  def link_user_to_social_login(%User{id: user_id}, {provider, uid}) do
    attrs = %{user_id: user_id, provider: provider, uid: uid}

    insert_social_login(attrs)
  end

  def link_user_to_social_login!(%User{} = user, social_info) do
    case link_user_to_social_login(user, social_info) do
      {:ok, social_login} ->
        social_login

      {:error, reason} ->
        raise """
        cannot link user to social login.
        Reason: #{inspect(reason)}
        """
    end
  end

  @doc """
  Gets the story count of a user.
  """
  def get_story_count(%User{} = author, opts \\ []) do
    query =
      if Keyword.get(opts, :published_only, false) do
        Story.published()
      else
        Story
      end
      |> Story.by_author(author)

    Repo.aggregate(query, :count, :id)
  end

  @doc """
  Gets the follower count of a user.
  """
  @spec get_follower_count(User.t()) :: non_neg_integer
  def get_follower_count(%User{} = user), do: Follows.get_follower_count(user: user)

  @doc """
  Gets the publication count of the user.

  ## Examples

      iex> get_publication_count(%User{})
      42

      iex> get_publication_count(%User{})
      0

  """
  @spec get_publication_count(User.t()) :: non_neg_integer
  def get_publication_count(%User{} = user) do
    query = PublicationMembership.by_member(user)

    Repo.aggregate(query, :count, :id)
  end
end
