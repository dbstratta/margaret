defmodule Margaret.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Margaret.Accounts.{User, SocialLogin}

  schema "users" do
    field :username, :string
    field :email, :string
    has_many :social_logins, SocialLogin

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
  end
end
