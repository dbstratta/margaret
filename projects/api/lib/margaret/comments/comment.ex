defmodule Margaret.Comments.Comment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Comment
  alias Margaret.Accounts.User
  alias Margaret.Stars.Star

  @typedoc "The Comment type"
  @type t :: %Comment{}

  schema "comments" do
    belongs_to :author, User
    field :body, :string
    many_to_many :stars, Star,
      join_through: "comment_stars",
      on_delete: :delete_all,
      unique: true

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:author_id, :body])
    |> validate_required([:author_id, :body])
    |> foreign_key_constraint(:author_id)
  end
end
