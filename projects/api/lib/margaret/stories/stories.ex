defmodule Margaret.Stories do
  @moduledoc """
  The Stories context.
  """

  alias Margaret.Repo
  alias Margaret.Stories.Story

  @doc """
  Gets a single story by its id.

  ## Examples

      iex> get_story(123)
      %Story{}

      iex> get_story(456)
      nil

  """
  @spec get_story(String.t) :: Story.t | nil
  def get_story(id), do: Repo.get(Story, id)

  @doc """
  Gets a single story by its id.

  Raises `Ecto.NoResultsError` if the Story does not exist.

  ## Examples

      iex> get_story!(123)
      %Story{}

      iex> get_story!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_story!(String.t) :: Story.t
  def get_story!(id), do: Repo.get!(Story, id)

  @spec get_story_by_slug(String.t) :: Story.t | nil
  def get_story_by_slug(slug), do: Repo.get_by(Story, slug: slug)

  @doc """
  Creates a story.
  """
  def create_story(attrs) do
    %Story{}
    |> Story.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a story.
  """
  def update_story(_attrs) do
  end

  @doc """
  Deletes a story.
  """
  def delete_story(id) do
    Repo.delete(%Story{id: id})
  end
end
