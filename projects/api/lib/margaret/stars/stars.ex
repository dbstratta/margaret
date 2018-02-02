defmodule Margaret.Stars do
  @moduledoc """
  The Stars context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{Repo, Accounts, Stars, Notifications, Workers}
  alias Accounts.User
  alias Stars.Star

  @doc """
  Gets a star.
  """
  def get_star(%{user_id: user_id, story_id: story_id}) do
    Repo.get_by(Star, user_id: user_id, story_id: story_id)
  end

  def get_star(%{user_id: user_id, comment_id: comment_id}) do
    Repo.get_by(Star, user_id: user_id, comment_id: comment_id)
  end

  @doc """
  """
  def has_starred?(args), do: !!get_star(args)

  @doc """
  Inserts a star.
  """
  def insert_star(%{user_id: user_id} = attrs) do
    star_changeset = Star.changeset(attrs)

    notification_attrs =
      attrs
      |> case do
        %{story_id: story_id} -> %{story_id: story_id}
        %{comment_id: comment_id} -> %{comment_id: comment_id}
      end
      |> Map.put(:actor_id, user_id)
      |> Map.put(:action, :starred)

    Multi.new()
    |> Multi.insert(:star, star_changeset)
    |> Workers.Notifications.enqueue_notification_insertion(notification_attrs)
    |> Repo.transaction()
  end

  def delete_star(id) when not is_map(id), do: Repo.delete(%Star{id: id})

  def delete_star(args) do
    case get_star(args) do
      %Star{id: id} -> delete_star(id)
      nil -> nil
    end
  end

  def get_star_count(%{story_id: story_id}) do
    query =
      from(
        s in Star,
        join: u in assoc(s, :user),
        where: s.story_id == ^story_id,
        where: is_nil(u.deactivated_at),
        select: count(s.id)
      )

    Repo.one!(query)
  end

  def get_star_count(%{comment_id: comment_id}) do
    query =
      from(
        s in Star,
        join: u in assoc(s, :user),
        where: s.comment_id == ^comment_id,
        where: is_nil(u.deactivated_at),
        select: count(s.id)
      )

    Repo.one!(query)
  end

  def get_story_star_count(story_id), do: get_star_count(%{story_id: story_id})

  def get_comment_star_count(comment_id), do: get_star_count(%{comment_id: comment_id})

  def get_starred_count(user_id) do
    query =
      from(
        s in Star,
        where: s.user_id == ^user_id,
        select: count(s.id)
      )

    Repo.one!(query)
  end
end
