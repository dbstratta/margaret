defmodule Margaret.Bookmarks do
  @moduledoc """
  The Bookmarks context.
  """

  import Ecto.Query

  alias Margaret.{
    Repo,
    Accounts.User,
    Bookmarks.Bookmark
  }

  @doc """
  Gets a bookmark.
  """
  def get_bookmark(%{user_id: user_id, story_id: story_id}) do
    Repo.get_by(Bookmark, user_id: user_id, story_id: story_id)
  end

  def get_bookmark(%{user_id: user_id, comment_id: comment_id}) do
    Repo.get_by(Bookmark, user_id: user_id, comment_id: comment_id)
  end

  @doc """
  Gets the user of a bookmark.
  """
  @spec get_user(Bookmark.t()) :: User.t()
  def get_user(%Bookmark{} = bookmark) do
    bookmark
    |> Bookmark.preload_user()
    |> Map.get(:user)
  end

  def has_bookmarked?(args), do: !!get_bookmark(args)

  @doc """
  Inserts a bookmark.
  """
  def insert_bookmark(attrs) do
    attrs
    |> Bookmark.changeset()
    |> Repo.insert()
  end

  def delete_bookmark(id) when is_integer(id) or is_binary(id), do: Repo.delete(%Bookmark{id: id})

  def delete_bookmark(args) do
    case get_bookmark(args) do
      %Bookmark{id: id} -> delete_bookmark(id)
      nil -> nil
    end
  end

  @doc """
  Gets the bookmarked count of a user.
  """
  @spec get_bookmarked_count(User.t()) :: non_neg_integer
  def get_bookmarked_count(%User{id: user_id}) do
    query = from(b in Bookmark, where: b.user_id == ^user_id, select: count(b.id))

    Repo.all(query)
  end
end
