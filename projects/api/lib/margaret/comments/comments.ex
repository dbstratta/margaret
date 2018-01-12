defmodule Margaret.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query
  alias Margaret.Repo

  alias Margaret.Comments.Comment

  @doc """
  Gets a comment by its id.

  ## Examples

      iex> get_comment(123)
      %Comment{}

      iex> get_comment(456)
      nil

  """
  @spec get_comment(term) :: Comment.t | nil
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
  @spec get_comment!(term) :: Story.t
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Gets the comment count of a commentable.

  ## Examples

      iex> get_comment_count(story_id: 123)
      42

      iex> get_comment_count(comment_id: 234)
      815

  """
  def get_comment_count(story_id: story_id) do
    query = from c in Comment,
      join: u in User, on: u.id == c.author_id,
      where: c.story_id == ^story_id,
      where: u.is_active == true,
      select: count(c.id)

    Repo.one!(query)
  end

  def get_comment_count(comment_id: comment_id) do
    query = from c in Comment,
      join: u in User, on: u.id == c.author_id,
      where: c.parent_id == ^comment_id,
      where: u.is_active == true,
      select: count(c.id)

    Repo.one!(query)
  end

  @doc """
  Creates a comment.
  """
  def create_comment(attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
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
  def delete_comment(id) do
    Repo.delete(%Comment{id: id})
  end
end
