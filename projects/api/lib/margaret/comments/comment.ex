defmodule Margaret.Comments.Comment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Comment
  alias Margaret.Accounts.User

  @typedoc "The Comment type"
  @type t :: %Comment{}

  schema "comments" do
    field :body, :string
    belongs_to :author, User

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:body, :author_id])
    |> validate_required([:body, :author_id])
    |> foreign_key_constraint(:author_id)
  end
end
