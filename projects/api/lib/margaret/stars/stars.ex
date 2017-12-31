defmodule Margaret.Stars do
  @moduledoc """
  The Stars context.
  """

  import Ecto.Query
  alias Margaret.Repo

  alias Margaret.Stars.Star

  def get_star(user_id: user_id, story_id: story_id) do
    Repo.get_by(Star, user_id: user_id, story_id: story_id)
  end

  def get_star(user_id: user_id, comment_id: comment_id) do
    Repo.get_by(Star, user_id: user_id, comment_id: comment_id)
  end

  def insert_star(attrs) do
    %Star{}
    |> Star.changeset(attrs)
    |> Repo.insert()
  end

  def delete_star(id) when not is_list(id), do: Repo.delete(%Star{id: id})

  def delete_star(user_id: user_id, story_id: story_id) do
    case get_star(user_id: user_id, story_id: story_id) do
      %Star{id: id} -> delete_star(id)
      nil -> nil
    end
  end

  def delete_star(user_id: user_id, comment_id: comment_id) do
    case get_star(user_id: user_id, comment_id: comment_id) do
      %Star{id: id} -> delete_star(id)
      nil -> nil
    end
  end

  def get_star_count(story_id: story_id) do
    Repo.one!(from s in Star, where: s.story_id == ^story_id, select: count(s.id))
  end

  def get_star_count(comment_id: comment_id) do
    Repo.one!(from s in Star, where: s.comment_id == ^comment_id, select: count(s.id))
  end

  def get_starred_count(user_id) do
    Repo.one!(from s in Star, where: s.user_id == ^user_id, select: count(s.id))
  end
end
