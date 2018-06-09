defmodule Margaret.CollectionStories do
  @moduledoc """
  The Collection Stories context.
  """

  alias Margaret.{
    Repo,
    Stories,
    CollectionStories
  }

  alias Stories.Story
  alias CollectionStories.CollectionStory

  @doc """
  Gets a collection story by a story id.
  Returns `nil` if the story isn't in a collection.
  """
  @spec get_collection_story(Story.t()) :: CollectionStory.t() | nil
  def get_collection_story(%Story{id: story_id}) do
    Repo.get_by(CollectionStory, story_id: story_id)
  end

  @doc """
  Inserts a collection story.
  """
  @spec insert_collection_story(map()) ::
          {:ok, CollectionStory.t()} | {:error, Ecto.Changeset.t()}
  def insert_collection_story(attrs) do
    attrs
    |> CollectionStory.changeset()
    |> Repo.insert()
  end

  @doc """
  Updates a collection story.
  """
  @spec update_collection_story(CollectionStory.t(), map()) ::
          {:ok, CollectionStory.t()} | {:error, Ecto.Changeset.t()}
  def update_collection_story(%CollectionStory{} = collection_story, attrs) do
    collection_story
    |> CollectionStory.update_changeset(attrs)
    |> Repo.update()
  end
end
