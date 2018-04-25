defmodule Margaret.Accounts.User do
  @moduledoc """
  The User schema and changesets.
  """

  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.{Query, Changeset}

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts,
    Publications,
    Collections.Collection,
    Stories.Story,
    Comments.Comment,
    Stars.Star,
    Bookmarks.Bookmark,
    Follows
  }

  alias Accounts.SocialLogin
  alias Publications.{Publication, PublicationMembership}
  alias Follows.Follow

  @type t :: %User{}

  @username_regex ~r/^[a-z\d](?:[a-z\d]|-(?=[a-z\d])){1,64}$/
  @email_regex ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,32}$/

  schema "users" do
    field(:username, :string)
    field(:email, :string)

    # When the user request a change of email, we store the new email in this field.
    # When the user verifies the email, we pass it to the `email` field and put `nil`
    # in this one.
    field(:unverified_email, :string)

    field(:first_name, :string)
    field(:last_name, :string)

    field(:avatar, User.Avatar.Type)
    field(:bio, :string)
    field(:website, :string)
    field(:location, :string)

    field(:is_admin, :boolean)
    field(:is_employee, :boolean)

    field(:deactivated_at, :naive_datetime)

    # A user can have many social accounts associated (Facebook, GitHub, etc.).
    has_many(:social_logins, SocialLogin)

    has_many(:stories, Story, foreign_key: :author_id)
    has_many(:comments, Comment, foreign_key: :author_id)

    has_many(:stars, Star)
    has_many(:bookmarks, Bookmark)

    has_many(:publication_memberships, PublicationMembership, foreign_key: :member_id)
    many_to_many(:publications, Publication, join_through: PublicationMembership)

    has_many(:collections, Collection, foreign_key: :author_id)

    many_to_many(
      :followers,
      User,
      join_through: Follow,
      join_keys: [user_id: :id, follower_id: :id]
    )

    many_to_many(
      :followees,
      User,
      join_through: Follow,
      join_keys: [follower_id: :id, user_id: :id]
    )

    embeds_one(:settings, Accounts.Settings, on_replace: :update)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a user.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
  def changeset(attrs) do
    permitted_attrs = ~w(
      username
      email
      bio
      website
      location
      is_admin
      is_employee
      deactivated_at
    )a

    required_attrs = ~w(
      username
      email
    )a

    %User{}
    |> cast(attrs, permitted_attrs)
    |> cast_attachments(attrs, [:avatar])
    |> validate_required(required_attrs)
    |> cast_embed(:settings, required: true)
    |> validate_format(:username, @username_regex)
    |> validate_format(:email, @email_regex)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc """
  Builds a changeset for updating a user.
  """
  @spec update_changeset(t(), map()) :: Ecto.Changeset.t()
  def update_changeset(%User{} = user, attrs) do
    permitted_attrs = ~w(
      username
      email
      unverified_email
      bio
      website
      location
      is_admin
      is_employee
      deactivated_at
    )a

    user
    |> cast(attrs, permitted_attrs)
    |> cast_embed(:settings, with: &Accounts.Settings.update_changeset/2)
    |> validate_format(:username, @username_regex)
    |> validate_format(:email, @email_regex)
    |> validate_format(:unverified_email, @email_regex)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc """
  Returns `true` if the string is a valid username.
  """
  @spec valid_username?(String.t()) :: boolean()
  def valid_username?(username), do: String.match?(username, @username_regex)

  @doc """
  Excludes deactivated users from the query.

  ## Examples

      iex> active()
      #Ecto.Query<...>

      iex> active(query)
      #Ecto.Query<...>

  """
  @spec active(Ecto.Queryable.t()) :: Ecto.Query.t()
  def active(query \\ User), do: where(query, [..., u], is_nil(u.deactivated_at))

  @doc """
  Filters out non-admin users from the query.

  ## Examples

      iex> admin()
      #Ecto.Query<...>

      iex> admin(query)
      #Ecto.Query<...>

  """
  @spec admin(Ecto.Queryable.t()) :: Ecto.Query.t()
  def admin(query \\ User), do: where(query, [..., u], u.is_admin)

  @doc """
  Filters out non-employee users from the query.

  ## Examples

      iex> employee()
      #Ecto.Query<...>

      iex> employee(query)
      #Ecto.Query<...>

  """
  @spec employee(Ecto.Queryable.t()) :: Ecto.Query.t()
  def employee(query \\ User), do: where(query, [..., u], u.is_employee)

  def followers(query \\ User, %User{id: user_id}, _opts \\ []) do
    from(
      u in query,
      join: f in Follow,
      on: f.follower_id == u.id,
      where: is_nil(u.deactivated_at),
      where: f.user_id == ^user_id,
      select: {u, %{followed_at: f.inserted_at}}
    )
  end

  @doc """
  Preloads the social logins of a user.
  """
  @spec preload_social_logins(Ecto.Queryable.t() | t()) :: Ecto.Query.t() | t()
  def preload_social_logins(%User{} = user), do: Repo.preload(user, :social_logins)
  def preload_social_logins(%Ecto.Query{} = query), do: preload(query, [..., u], :social_logins)

  @doc """
  Ecto query helper to filter user settings that have enabled
  notifications for new stories.

  ## Examples

      iex> from u in User, where: new_story_notifications_enabled(u.settings)
      #Ecto.Query<...>

  """
  @spec new_story_notifications_enabled(any()) :: Macro.t()
  defmacro new_story_notifications_enabled(settings) do
    quote do
      fragment("(?->'notifications'->>'new_stories')::boolean = true", unquote(settings))
    end
  end
end
