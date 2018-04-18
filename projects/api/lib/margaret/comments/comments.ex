defmodule Margaret.Comments do
  @moduledoc """
  The Comments context.
  """

  import Ecto.Query
  alias Margaret.Repo

  alias Margaret.{
    Accounts,
    Stories,
    Comments
  }

  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment

  @type commentable :: Story.t() | Comment.t()

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
  @spec get_comment!(String.t() | non_neg_integer()) :: Comment.t() | no_return()
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Returns the story of a comment.
  """
  @spec story(Comment.t()) :: Story.t()
  def story(%Comment{} = comment) do
    comment
    |> Comment.preload_story()
    |> Map.fetch!(:story)
  end

  @doc """
  Returns the author of a comment.
  """
  @spec author(Comment.t()) :: User.t()
  def author(%Comment{} = comment) do
    comment
    |> Comment.preload_author()
    |> Map.fetch!(:author)
  end

  @doc """
  Returns the parent of a comment.
  """
  @spec parent(Comment.t()) :: User.t()
  def parent(%Comment{} = comment) do
    comment
    |> Comment.preload_parent()
    |> Map.fetch!(:parent)
  end

  @doc """
  Gets the comment count of a commentable.

  ## Examples

      iex> comment_count([story: %Story{}])
      815

      iex> comment_count([comment: %Comment{}])
      42

  """
  @spec comment_count(Keyword.t()) :: non_neg_integer()
  def comment_count(clauses) do
    query =
      clauses
      |> get_commentable_from_clauses()
      |> case do
        %Story{} = story -> Comment.by_story(story)
        %Comment{} = comment -> Comment.by_parent(comment)
      end

    query
    |> join(:inner, [c], u in assoc(c, :author))
    |> User.active()
    |> Repo.count()
  end

  @spec get_commentable_from_clauses(Keyword.t()) :: commentable()
  defp get_commentable_from_clauses(clauses) do
    cond do
      Keyword.has_key?(clauses, :story) -> Keyword.get(clauses, :story)
      Keyword.has_key?(clauses, :comment) -> Keyword.get(clauses, :comment)
    end
  end

  @doc """
  Returns `true` if the user can see the comment.
  `false` otherwise.
  """
  @spec can_see_comment?(Comment.t(), User.t()) :: boolean
  def can_see_comment?(%Comment{} = comment, %User{} = user) do
    comment
    |> story()
    |> Stories.can_see_story?(user)
  end

  @doc """
  Inserts a comment.
  """
  @spec insert_comment(map()) :: {:ok, Comment.t()} | {:error, Ecto.Changeset.t()}
  def insert_comment(attrs) do
    attrs
    |> Comment.changeset()
    |> Repo.insert()
  end

  @doc """
  Updates a comment.
  """
  @spec update_comment(Comment.t(), map()) :: {:ok, Comment.t()} | {:error, Ecto.Changeset.t()}
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(%Comment{})
      {:ok, %Comment{}}

  """
  @spec delete_comment(Comment.t()) :: {:ok, Comment.t()} | {:error, Ecto.Changeset.t()}
  def delete_comment(%Comment{} = comment), do: Repo.delete(comment)
end
