defmodule Margaret.Stories.Story do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Story
  alias Margaret.Accounts.User
  alias Margaret.Stars.{Star, StoryStar}
  alias Margaret.Comments.Comment

  @typedoc "The Story type"
  @type t :: %Story{}

  schema "stories" do
    field :title, :string
    field :body, :string
    belongs_to :author, User
    field :summary, :string
    field :slug, :string
    has_many :stars, StoryStar
    has_many :comments, {"story_comments", Comment}, foreign_key: :assoc_id

    timestamps()
  end

  @doc false
  def changeset(%Story{} = story, attrs) do
    story
    |> cast(attrs, [:title, :body, :user_id, :summary])
    |> validate_required([:title, :body])
    |> foreign_key_constraint(:user_id)
  end
end
