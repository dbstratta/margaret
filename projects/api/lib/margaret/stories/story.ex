defmodule Margaret.Stories.Story do
  use Ecto.Schema

  alias Margaret.Accounts.User

  schema "stories" do
    field :title, :string
    field :body, :string

    belongs_to :author, User

    timestamps()
  end
end
