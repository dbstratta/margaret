defmodule Margaret.Bookmarks do
  @moduledoc """
  The Bookmarks context.
  """

  import Ecto.Query
  alias Margaret.Repo

  alias Margaret.Bookmarks.Bookmark

  @doc """
  Gets a bookmark.
  """
  def get_bookmark(%{user_id: user_id, story_id: story_id}) do
    Repo.get_by(Bookmark, user_id: user_id, story_id: story_id)
  end

  def get_bookmark(%{user_id: user_id, comment_id: comment_id}) do
    Repo.get_by(Bookmark, user_id: user_id, comment_id: comment_id)
  end

  def has_bookmarked(args), do: !!get_bookmark(args)

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

  def get_bookmarked_count(user_id) do
    Repo.all(from(b in Bookmark, where: b.user_id == ^user_id, select: count(b.id)))
  end
end
