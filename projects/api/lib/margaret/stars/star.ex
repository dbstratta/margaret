defmodule Margaret.Stars.Star do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Star
  alias Margaret.Accounts.User

  @typedoc "The Star type"
  @type t :: %Star{}

  schema "stars" do
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Star{} = star, attrs) do
    star
    |> cast(attrs, [:story_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
  end
end
