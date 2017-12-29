defmodule Margaret.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Stories, Publications}
  alias Accounts.{SocialLogin, Follow}
  alias Stories.Story
  alias Publications.{Publication, PublicationMembership}

  @type t :: %User{}

  @permitted_attrs [
    :username,
    :email,
  ]

  @required_attrs [
    :username,
    :email,
  ]

  schema "users" do
    field :username, :string
    field :email, :string
    has_many :social_logins, SocialLogin

    has_many :stories, Story, foreign_key: :author_id

    has_many :followers, Follow 
    has_many :followees, Follow, foreign_key: :follower_id

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
