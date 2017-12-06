defmodule Margaret.Comments.StoryComment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: StoryComment
  alias Margaret.Accounts.User
  alias Margaret.Stories.Story

  @typedoc "The StoryComment type"
  @type t :: %StoryComment{}

  schema "story_comments" do
    belongs_to :story, Story
    belongs_to :author, User
    field :body, :string

    timestamps()
  end

  @doc false
  def changeset(%StoryComment{} = story_comment, attrs) do
    story_comment
    |> cast(attrs, [:story_id, :author_id, :body])
    |> validate_required([:story_id, :author_id, :body])
    |> foreign_key_constraint(:story_id)
    |> foreign_key_constraint(:author_id)
  end
end
