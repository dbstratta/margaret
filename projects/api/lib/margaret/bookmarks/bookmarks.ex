defmodule Margaret.Bookmarks do
  @moduledoc """
  The Bookmarks context.
  """

  alias Margaret.{
    Repo,
    Accounts.User,
    Bookmarks.Bookmark
  }

  @doc """
  Gets a bookmark.

  ## Examples

      iex> get_bookmark(user_id: 123, story_id: 123)
      %Bookmark{}

      iex> get_bookmark(user_id: 123, comment_id: 456)
      nil

  """
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

      iex> has_bookmarked?(user_id: 123, comment_id: 123)
      true

  """
  @spec has_bookmarked?(Keyword.t()) :: boolean
  def has_bookmarked?(clauses), do: !!get_bookmark(clauses)

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
