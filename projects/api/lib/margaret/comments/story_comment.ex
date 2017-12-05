defmodule Margaret.Comments.StoryComment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: StoryComment
  alias Margaret.Stories.Story
  alias Margaret.Comments.Comment

  @typedoc "The StoryComment type"
  @type t :: %StoryComment{}

  schema "story_comments" do
    belongs_to :story, Story
    belongs_to :comment, Comment

    timestamps()
  end

  @doc false
  def changeset(%StoryComment{} = story_comment, attrs) do
    story_comment
    |> cast(attrs, [:story_id, :comment_id])
    |> validate_required([:story_id, :comment_id])
    |> foreign_key_constraint(:story_id)
    |> foreign_key_constraint(:comment_id)
  end
end
