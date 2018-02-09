defmodule Margaret.Bookmarks do
  @moduledoc """
  The Bookmarks context.
  """

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Comments,
    Collections,
    Bookmarks
  }

  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment
  alias Collections.Collection
  alias Bookmarks.Bookmark

  @type bookmarkable :: Collection.t() | Story.t() | Comment.t()

  @doc """
  Gets a bookmark.

  ## Examples

      iex> get_bookmark(user_id: 123, story_id: 123)
      %Bookmark{}

      iex> get_bookmark(user_id: 123, comment_id: 456)
      nil

  """
  @spec get_bookmark(Keyword.t()) :: Bookmark.t() | nil
  def get_bookmark(clauses) when length(clauses) == 2, do: Repo.get_by(Bookmark, clauses)

  @doc """
  Gets the user of a bookmark.

  ## Examples

      iex> get_user(%Bookmark{})
      %User{}

  """
  @spec get_user(Bookmark.t()) :: User.t()
  def get_user(%Bookmark{} = bookmark) do
    bookmark
    |> Bookmark.preload_user()
    |> Map.get(:user)
  end

  @doc """
  Returns `true` if the user has bookmarked the bookmarkable.
  `false` otherwise.

  ## Examples

      iex> has_bookmarked?(user: %User{}, comment: %Comment{})
      true

      iex> has_bookmarked?(user: %User{}, collection: %Collection{})
      false

  """
  @spec has_bookmarked?(Keyword.t()) :: boolean
  def has_bookmarked?(clauses) do
    %User{id: user_id} = Keyword.get(clauses, :user)

    clauses =
      clauses
      |> get_bookmarkable_from_clauses()
      |> case do
        %Collection{id: collection_id} -> [collection_id: collection_id]
        %Story{id: story_id} -> [story_id: story_id]
        %Comment{id: comment_id} -> [comment_id: comment_id]
      end
      |> Keyword.put(:user_id, user_id)

    !!get_bookmark(clauses)
  end

  @spec get_bookmarkable_from_clauses(Keyword.t()) :: bookmarkable
  defp get_bookmarkable_from_clauses(clauses) do
    cond do
      Keyword.has_key?(clauses, :collection) -> Keyword.get(clauses, :collection)
      Keyword.has_key?(clauses, :story) -> Keyword.get(clauses, :story)
      Keyword.has_key?(clauses, :comment) -> Keyword.get(clauses, :comment)
    end
  end

  @doc """
  Inserts a bookmark.
  """
  def insert_bookmark(attrs) do
    attrs
    |> Bookmark.changeset()
    |> Repo.insert()
  end

  @doc """
  Deletes a bookmark.
  """
  @spec delete_bookmark(Bookmark.t()) :: Bookmark.t()
  def delete_bookmark(%Bookmark{} = bookmark), do: Repo.delete(bookmark)

  @doc """
  Gets the bookmarked count of a user.

  ## Examples

      iex> get_bookmarked_count(%User{})
      42

  """
  @spec get_bookmarked_count(User.t()) :: non_neg_integer
  def get_bookmarked_count(%User{} = user) do
    query = Bookmark.by_user(user)

    Repo.aggregate(query, :count, :id)
  end
end
