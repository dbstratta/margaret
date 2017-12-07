defmodule Margaret.Stories.Story do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Story
  alias Margaret.Accounts.User
  alias Margaret.Stars.Star
  alias Margaret.Comments.Comment

  @typedoc "The Story type"
  @type t :: %Story{}

  schema "stories" do
    field :title, :string
    field :body, :string
    belongs_to :author, User
    field :summary, :string
    field :slug, :string
    many_to_many :stars, Star,
      join_through: "story_stars",
      on_delete: :delete_all,
      unique: true
    many_to_many :comments, Comment,
      join_through: "story_comments",
      on_delete: :delete_all,
      unique: true

    timestamps()
  end

  @doc false
  def changeset(%Story{} = story, attrs) do
    story
    |> cast(attrs, [:title, :body, :author_id, :summary])
    |> validate_required([:title, :body])
    |> foreign_key_constraint(:author_id)
  end
end
