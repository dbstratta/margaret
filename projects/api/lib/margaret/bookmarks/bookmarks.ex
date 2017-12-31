defmodule Margaret.Bookmarks do
  @moduledoc """
  The Bookmarks context.
  """

  import Ecto.Query
  alias Margaret.Repo

  alias Margaret.Bookmarks.Bookmark

  def get_bookmark(user_id: user_id, story_id: story_id) do
    Repo.get_by(Bookmark, user_id: user_id, story_id: story_id)
  end

  def get_bookmark(user_id: user_id, comment_id: comment_id) do
    Repo.get_by(Bookmark, user_id: user_id, comment_id: comment_id)
  end

  def insert_bookmark(attrs) do
    %Bookmark{}
    |> Bookmark.changeset(attrs)
    |> Repo.insert()
  end

  def delete_bookmark(id) when not is_list(id), do: Repo.delete(%Bookmark{id: id})

  def delete_bookmark(user_id: user_id, story_id: story_id) do
    case get_bookmark(user_id: user_id, story_id: story_id) do
      %Bookmark{id: id} -> delete_bookmark(id)
      nil -> nil
    end
  end

  def delete_bookmark(user_id: user_id, comment_id: comment_id) do
    case get_bookmark(user_id: user_id, comment_id: comment_id) do
      %Bookmark{id: id} -> delete_bookmark(id)
      nil -> nil
    end
  end

  def get_bookmarked_count(user_id) do
    Repo.all(from b in Bookmark, where: b.user_id == ^user_id, select: count(b.id))
  end
end
