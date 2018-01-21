defmodule Margaret.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{Repo, Accounts, Publications}
  alias Accounts.{User, SocialLogin, Follow}
  alias Publications.PublicationMembership

  # 15 days.
  @seconds_before_user_deletion 60 * 60 * 24 * 15

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
  def get_user_by_username(username, opts \\ []) do
    query = from(u in User, where: u.username == ^username)

    query
    |> maybe_include_deactivated(opts)
    |> Repo.one()
  end

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
  def get_user_by_username!(username, opts \\ []) do
    query = from(u in User, where: u.username == ^username)

    query
    |> maybe_include_deactivated(opts)
    |> Repo.one!()
  end

  @doc """
  Gets a user by its email.

  ## Examples

      iex> get_user_by_email("user@example.com")
      %User{}

      iex> get_user_by_email("user@example.com")
      nil

  """
  @spec get_user_by_email(String.t(), Keyword.t()) :: User.t() | nil
  def get_user_by_email(email, opts \\ []) do
    query = from(u in User, where: u.email == ^email)

    query
    |> maybe_include_deactivated(opts)
    |> Repo.one()
  end

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
  def get_user_by_email!(email, opts \\ []) do
    query = from(u in User, where: u.email == ^email)

    query
    |> maybe_include_deactivated(opts)
    |> Repo.one!()
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
  @spec get_user_by_social_login!({atom, String.t()}) :: User.t() | nil
  def get_user_by_social_login!({provider, uid}, opts \\ []) do
    query =
      from(
        u in User,
        join: s in SocialLogin,
        on: s.user_id == u.id,
        where: s.provider == ^provider and s.uid == ^uid
      )

    query
    |> maybe_include_deactivated(opts)
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
    query = from(u in User, select: count(u.id))

    query
    |> maybe_include_deactivated(opts)
    |> Repo.one!()
  end

  defp maybe_include_deactivated(query, opts) do
    opts
    |> Keyword.get(:include_deactivated, false)
    |> do_maybe_include_deactivated(query)
  end

  defp do_maybe_include_deactivated(false, query) do
    from(u in query, where: is_nil(u.deactivated_at))
  end

  defp do_maybe_include_deactivated(true, query), do: query

  def member?(%User{}), do: false

  @doc """
  Inserts a user.

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
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
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
  def mark_user_for_deletion(%User{id: user_id} = user, seconds \\ @seconds_before_user_deletion) do
    user_changeset = User.update_changeset(user, %{})

    schedule_deletion = fn _ ->
      Exq.enqueue_in(Exq, "user_deletion", seconds, MargaretWeb.Workers.DeleteAccount, [user_id])
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
  Gets the publication count of the user.

  ## Examples

    iex> get_publication_count(123)
    42

    iex> get_publication_count(234)
    0

  """
  @spec get_publication_count(String.t() | non_neg_integer) :: non_neg_integer
  def get_publication_count(user_id) do
    query =
      from(
        pm in PublicationMembership,
        where: pm.member_id == ^user_id,
        select: count(pm.id)
      )

    Repo.one!(query)
  end

  @doc """
  Gets a follow.

  ## Examples

      iex> get_follow(123)
      %Follow{}

      iex> get_follow(456)
      nil

      iex> get_follow(%{follower_id: 123, user_id: 234})
      %Follow{}

      iex> get_follow(%{follower_id: 123, publication_id: 234})
      nil

  """
  @spec get_follow(String.t() | non_neg_integer) :: Follow.t() | nil
  def get_follow(id) when is_integer(id) or is_binary(id), do: Repo.get(Follow, id)

  @spec get_follow(%{optional(atom) => any}) :: Follow.t() | nil
  def get_follow(%{follower_id: follower_id, user_id: user_id}) do
    Repo.get_by(Follow, follower_id: follower_id, user_id: user_id)
  end

  def get_follow(%{follower_id: follower_id, publication_id: publication_id}) do
    Repo.get_by(Follow, follower_id: follower_id, publication_id: publication_id)
  end

  @doc """
  Gets the followee count of a user.

  ## Examples

    iex> get_followee_count(123)
    42

  """
  def get_followee_count(user_id) do
    Repo.one!(from(f in Follow, where: f.follower_id == ^user_id, select: count(f.id)))
  end

  @doc """
  Gets the follower count of a followable.

  ## Examples

    iex> get_follower_count(%{user_id: 123})
    42

    iex> get_follower_count(%{publication_id: 234})
    815

  """
  def get_follower_count(%{user_id: user_id}) do
    Repo.one!(from(f in Follow, where: f.user_id == ^user_id, select: count(f.id)))
  end

  def get_follower_count(%{publication_id: publication_id}) do
    Repo.one!(from(f in Follow, where: f.publication_id == ^publication_id, select: count(f.id)))
  end

  @doc """
  Inserts a follow.

  ## Examples

    iex> insert_follow(attrs)
    {:ok, %Follow{}}

    iex> insert_follow(attrs)
    {:error, %Ecto.Changeset{}}

    iex> insert_follow(attrs)
    {:error, reason}

  """
  def insert_follow(%{user_id: user_id} = attrs) when is_binary(user_id) do
    attrs
    |> Map.update!(:user_id, &String.to_integer(&1))
    |> insert_follow()
  end

  def insert_follow(%{publication_id: publication_id} = attrs) when is_binary(publication_id) do
    attrs
    |> Map.update!(:publication_id, &String.to_integer(&1))
    |> insert_follow()
  end

  def insert_follow(%{follower_id: follower_id, user_id: user_id}) when follower_id === user_id do
    {:error, "You can't follow yourself."}
  end

  def insert_follow(attrs) do
    attrs
    |> Follow.changeset()
    |> Repo.insert()
  end

  @doc """
  Deletes a follow.

  ## Examples

    iex> delete_follow(123)
    {:ok, %Follow{}}

    iex> delete_follow(%{follower_id: 123, publication_id: 234})
    {:ok, %Follow{}}

    iex> delete_follow(%{follower_id: 123, user_id: 234})
    {:error, %Ecto.Changeset{}}

  """
  def delete_follow(id) when is_integer(id) or is_binary(id), do: Repo.delete(%Follow{id: id})

  def delete_follow(args) do
    case get_follow(args) do
      %Follow{id: id} -> delete_follow(id)
      nil -> nil
    end
  end
end
