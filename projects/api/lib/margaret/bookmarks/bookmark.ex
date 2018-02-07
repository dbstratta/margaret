defmodule Margaret.Bookmarks.Bookmark do
  @moduledoc """
  The Bookmark schema and changesets.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias __MODULE__

  alias Margaret.{
    Repo,
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

  @doc """
  Filters the bookmarks by user.
  """
  @spec by_user(Ecto.Query.t(), User.t()) :: Ecto.Query.t()
  def by_user(query \\ Bookmark, %User{id: user_id}),
    do: where(query, [..., b], b.user_id == ^user_id)

  @doc """
  Preloads the user of a bookmark.
  """
  @spec preload_user(t) :: t
  def preload_user(%Bookmark{} = bookmark), do: Repo.preload(bookmark, :user)

  @doc """
  Preloads the story of a bookmark.
  """
  @spec preload_story(t) :: t
  def preload_story(%Bookmark{} = bookmark), do: Repo.preload(bookmark, :story)

  @doc """
  Preloads the comment of a bookmark.
  """
  @spec preload_comment(t) :: t
  def preload_comment(%Bookmark{} = bookmark), do: Repo.preload(bookmark, :comment)
end
