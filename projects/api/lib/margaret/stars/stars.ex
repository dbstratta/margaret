defmodule Margaret.Stars do
  @moduledoc """
  The Stars context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{Repo, Accounts, Stars, Workers}
  alias Accounts.User
  alias Stars.Star

  @doc """
  Gets a star.
  """
  @spec get_star(Keyword.t()) :: Star.t() | nil
  def get_star(clauses) when length(clauses) == 2, do: Repo.get_by(Star, clauses)

  @doc """
  """
  @spec has_starred?(Keyword.t()) :: boolean
  def has_starred?(clauses), do: !!get_star(clauses)

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

  @doc """
  Deletes a star.
  """
  def delete_star(%Star{} = star), do: Repo.delete(star)

  @doc """
  Gets the star count of a starrable.

  ## Examples

      iex> get_star_count(story: %Story{})
      42

      iex> get_star_count(comment: %Comment{})
      0

  """
  def get_star_count(clauses) do
    query =
      cond do
        Keyword.has_key?(clauses, :story) ->
          clauses
          |> Keyword.get(:story)
          |> Star.by_story()

        Keyword.has_key?(clauses, :comment) ->
          clauses
          |> Keyword.get(:comment)
          |> Star.by_comment()
      end
      |> join(:inner, [star], u in assoc(star, :user))
      |> User.active()

    Repo.aggregate(query, :count, :id)
  end

  @doc """
  Gets the starred count of a user.

  ## Examples

      iex> get_starred_count(%User{})
      42

      iex> get_starred_count(%User{})
      0

  """
  def get_starred_count(%User{} = user) do
    query = Star.by_user(user)

    Repo.aggregate(query, :count, :id)
  end
end
