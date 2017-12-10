defmodule Margaret.Comments.Comment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Comment
  alias Margaret.{Accounts, Stories, Stars}
  alias Accounts.User
  alias Stories.Story
  alias Stars.Star

  @typedoc "The Comment type"
  @type t :: %Comment{}

  schema "comments" do
    field :body, :string
    belongs_to :author, User
    has_many :stars, Star

    belongs_to :story, Story

    timestamps()
  end

  @doc false
  def changeset(%Comment{} = comment, attrs) do
    comment
    |> cast(attrs, [:author_id, :body, :story_id])
    |> validate_required([:author_id, :body])
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:story_id)
  end
end
