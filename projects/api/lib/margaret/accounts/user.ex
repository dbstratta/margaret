defmodule Margaret.Accounts.User do
  @moduledoc """
  The User schema and changesets.
  """

  use Ecto.Schema
  import Ecto.{Query, Changeset}

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts,
    Publications,
    Stories.Story,
    Comments.Comment,
    Stars.Star,
    Bookmarks.Bookmark
  }

  alias Accounts.{SocialLogin, Follow}
  alias Publications.{Publication, PublicationMembership}

  @type t :: %User{}

  @username_regex ~r/^[a-z\d](?:[a-z\d]|-(?=[a-z\d])){1,64}$/

  @email_regex ~r/@/
  @email_min_length 3
  @email_max_length 254

  schema "users" do
    field(:username, :string)
    field(:email, :string)

    field(:is_admin, :boolean)
    field(:is_employee, :boolean)

    field(:deactivated_at, :naive_datetime)

    # A user can have many social logins associated (Facebook, GitHub, etc.).
    has_many(:social_logins, SocialLogin)

    has_many(:stories, Story, foreign_key: :author_id)
    has_many(:comments, Comment, foreign_key: :author_id)

    has_many(:stars, Star)
    has_many(:bookmarks, Bookmark)

    many_to_many(:publications, Publication, join_through: PublicationMembership)

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

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a user.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      username
      email
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
    |> validate_required(required_attrs)
    |> validate_format(:username, @username_regex)
    |> validate_format(:email, @email_regex)
    |> validate_length(:email, min: @email_min_length, max: @email_max_length)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc """
  Builds a changeset for updating a user.
  """
  def update_changeset(%User{} = user, attrs) do
    permitted_attrs = ~w(
      username
      email
      is_admin
      is_employee
      deactivated_at
    )a

    user
    |> cast(attrs, permitted_attrs)
    |> validate_format(:username, @username_regex)
    |> validate_format(:email, @email_regex)
    |> validate_length(:email, min: @email_min_length, max: @email_max_length)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  @doc """
  Returns `true` if the string is a valid username.
  """
  @spec valid_username?(String.t()) :: boolean
  def valid_username?(username), do: String.match?(username, @username_regex)

  @doc """
  Excludes deactivated users from the query.

  ## Examples

    iex> from(u in User, where: u.is_admin) |> exclude_deactivated()
    #Ecto.Query<...>

  """
  def exclude_deactivated(query \\ __MODULE__), do: where(query, [u], is_nil(u.deactivated_at))

  @spec preload_social_logins(t) :: t
  def preload_social_logins(%User{} = user), do: Repo.preload(user, :social_logins)
end
