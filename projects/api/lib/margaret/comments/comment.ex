defmodule Margaret.Comments.Comment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Comment
  alias Margaret.Accounts.User

  @typedoc "The Comment type"
  @type t :: %Comment{}

  schema "comments" do
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
  end
end
