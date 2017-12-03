defmodule Margaret.Accounts.User do
  use Ecto.Schema

  alias Margaret.Accounts.SocialLogins

  schema "users" do
    field :username, :string
    field :email, :string
    has_many :social_logins, SocialLogins

    timestamps()
  end
end
