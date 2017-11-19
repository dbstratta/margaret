defmodule Margaret.Accounts.User do
  use Ecto.Schema

  schema "users" do
    field :username, :string
    field :email, :string

    timestamps()
  end
end
