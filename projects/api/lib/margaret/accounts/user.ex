defmodule Margaret.Accounts.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: User
  alias Margaret.{Accounts, Stories, Publications}
  alias Accounts.SocialLogin
  alias Stories.Story
  alias Publications.{Publication, PublicationMembership}

  @typedoc "The User type"
  @type t :: %User{}

  schema "users" do
    field :username, :string
    field :email, :string
    has_many :social_logins, SocialLogin
    has_many :stories, Story, foreign_key: :author_id
    many_to_many :publications, Publication,
      join_through: PublicationMembership

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
    |> validate_length(:username, min: 2, max: 64)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:email, min: 3, max: 254)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
