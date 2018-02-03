defmodule Margaret.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query
  alias Margaret.Repo

  alias Margaret.{Accounts, Stories, Comments}
  alias Accounts.User
  alias Comments.Comment

  @doc """
  Gets a comment by its id.

  ## Examples

      iex> get_comment(123)
      %Comment{}

      iex> get_comment(456)
      nil

  """
  @spec get_comment(String.t() | non_neg_integer) :: Comment.t() | nil
  def get_comment(id), do: Repo.get(Comment, id)

  @doc """
  Gets a comment by its id.

  Raises `Ecto.NoResultsError` if the comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_comment!(String.t() | non_neg_integer) :: Comment.t() | no_return
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Gets the story of a comment.
  """
  @spec get_story(Comment.t()) :: Story.t()
  def get_story(%Comment{} = comment) do
    comment
    |> Comment.preload_story()
    |> Map.get(:story)
  end

  @doc """
  Gets the comment count of a commentable.

  ## Examples

      iex> get_comment_count(%{story_id: 123})
      42

      iex> get_comment_count(%{comment_id: 234})
      815

  """
  def get_comment_count(%{story_id: story_id}) do
    query = from(c in Comment, where: c.story_id == ^story_id)

    do_get_comment_count(query)
  end

  def get_comment_count(%{comment_id: comment_id}) do
    query = from(c in Comment, where: c.parent_id == ^comment_id)

    do_get_comment_count(query)
  end

  defp do_get_comment_count(query) do
    query =
      from(
        c in query,
        join: u in assoc(c, :author),
        where: is_nil(u.deactivated_at),
        select: count(c.id)
      )

    Repo.one!(query)
  end

  def get_story_comment_count(story_id), do: get_comment_count(%{story_id: story_id})

  def get_comment_comment_count(comment_id), do: get_comment_count(%{comment_id: comment_id})

  def can_see_comment?(%Comment{} = comment, %User{} = user) do
    comment
    |> get_story()
    |> Stories.can_see_story?(user)
  end

  @doc """
  Inserts a comment.
  """
  def insert_comment(attrs) do
    attrs
    |> Comment.changeset()
    |> Repo.insert()
  end

  @doc """
  Updates a comment.
  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.
  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end
end
