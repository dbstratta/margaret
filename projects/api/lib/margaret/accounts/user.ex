defmodule Margaret.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Stories, Publications, Stars, Bookmarks}
  alias Accounts.{SocialLogin, Follow}
  alias Stories.Story
  alias Publications.{Publication, PublicationMembership}
  alias Stars.Star
  alias Bookmarks.Bookmark

  @type t :: %User{}

  @permitted_attrs [
    :username,
    :email,
    :is_admin,
    :is_employee,
  ]

  @required_attrs [
    :username,
    :email,
  ]

  schema "users" do
    field :username, :string
    field :email, :string

    field :is_admin, :boolean
    field :is_employee, :boolean

    has_many :social_logins, SocialLogin

    has_many :stories, Story, foreign_key: :author_id
    has_many :stars, Star
    has_many :bookmarks, Bookmark

    many_to_many :followers, User, join_through: Follow, join_keys: [user_id: :id, follower_id: :id] 
    many_to_many :followees, User, join_through: Follow, join_keys: [follower_id: :id, user_id: :id]

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> validate_length(:username, min: 2, max: 64)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:email, min: 3, max: 254)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
