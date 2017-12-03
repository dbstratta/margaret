defmodule Margaret.Accounts.SocialLogins do
  use Ecto.Schema

  alias Margaret.Accounts.User

  schema "social_logins" do
    field :uid, :string
    field :provider, :string
    belongs_to :user, User

    timestamps()
  end
end
