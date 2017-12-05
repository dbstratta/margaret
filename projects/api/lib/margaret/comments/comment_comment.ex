defmodule Margaret.Comments.CommentComment do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: CommentComment
  alias Margaret.Stories.Story
  alias Margaret.Comments.Comment

  @typedoc "The CommentComment type"
  @type t :: %CommentComment{}

  schema "comment_comments" do
    belongs_to :parent_comment, Comment
    belongs_to :comment, Comment

    timestamps()
  end

  @doc false
  def changeset(%CommentComment{} = comment_comment, attrs) do
    comment_comment
    |> cast(attrs, [:parent_comment_id, :comment_id])
    |> validate_required([:parent_comment_id, :comment_id])
    |> foreign_key_constraint(:parent_comment_id)
    |> foreign_key_constraint(:comment_id)
  end
end
