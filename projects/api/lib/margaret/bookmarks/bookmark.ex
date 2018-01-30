defmodule Margaret.Bookmarks.Bookmark do
  @moduledoc """
  The Bookmark schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias Margaret.{
    Accounts.User,
    Stories.Story,
    Comments.Comment
  }

  @type t :: %Bookmark{}

  schema "bookmarks" do
    # The user that bookmarked the bookmarkable.
    belongs_to(:user, User)

    # Bookmarkables.
    belongs_to(:story, Story)
    belongs_to(:comment, Comment)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a bookmark.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      user_id
      story_id
      comment_id
    )a

    required_attrs = ~w(
      user_id
    )a

    %Bookmark{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:user)
    |> assoc_constraint(:story)
    |> assoc_constraint(:comment)
    |> unique_constraint(:user, name: :bookmarks_user_id_story_id_index)
    |> unique_constraint(:user, name: :bookmarks_user_id_comment_id_index)
    |> check_constraint(:user, name: :only_one_not_null_bookmarkable)
  end
end
