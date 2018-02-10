defmodule Margaret.Collections do
  @moduledoc """
  The Collections context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Publications,
    Collections,
    Tags
  }

  alias Accounts.User
  alias Stories.Story
  alias Publications.Publication
  alias Collections.{Collection, CollectionStory}
  alias Tags.Tag

  @doc """
  Gets a collection.

  ## Examples

      iex> get_collection(123)
      %Collection{}

      iex> get_collection(456)
      nil

  """
  @spec get_collection(String.t() | non_neg_integer) :: Collection.t() | nil
  def get_collection(id), do: Repo.get(Collection, id)

  @doc """
  Gets a collection by its slug.

  ## Examples

      iex> get_collection_by_slug("my-collection")
      %Collection{}

      iex> get_collection_by_slug("no-collection")
      nil

  """
  @spec get_collection_by_slug(String.t()) :: Collection.t() | nil
  def get_collection_by_slug(slug), do: get_collection_by(slug: slug)

  @spec get_collection_by(Keyword.t()) :: Collection.t() | nil
  defp get_collection_by(clauses), do: Repo.get_by(Collection, clauses)

  @doc """
  Gets the author of the collection.

  ## Examples

      iex> get_author(%Collection{})
      %User{}

  """
  @spec get_author(Collection.t()) :: User.t()
  def get_author(%Collection{} = collection) do
    collection
    |> Collection.preload_author()
    |> Map.get(:author)
  end

  @doc """
  Gets the publication of the collection.

  ## Examples

      iex> get_publication(%Collection{})
      %Publication{}

      iex> get_publication(%Collection{})
      nil

  """
  @spec get_publication(Collection.t()) :: Publication.t() | nil
  def get_publication(%Collection{} = collection) do
    collection
    |> Collection.preload_publication()
    |> Map.get(:publication)
  end

  @doc """
  Gets the tags of the collection.

  ## Examples

      iex> get_tags(%Collection{})
      [%Tag{}]

  """
  @spec get_tags(Collection.t()) :: [Tag.t()]
  def get_tags(%Collection{} = collection) do
    collection
    |> Collection.preload_tags()
    |> Map.get(:tags)
  end

  @doc """
  Returns `true` if the story is in the collection.
  `false` otherwise.

  ## Examples

      iex> in_collection?(%Collection{}, %Story{})
      true

  """
  @spec in_collection?(Collection.t(), Story.t()) :: boolean
  def in_collection?(%Collection{id: collection_id}, %Story{} = story) do
    case Stories.get_collection(story) do
      %Collection{id: story_collection_id} when story_collection_id === collection_id -> true
      _ -> false
    end
  end

  @doc """
  Inserts a collection.
  """
  def insert_collection(attrs) do
    attrs
    |> Collection.changeset()
    |> Repo.insert()
  end

  @doc """
  Updates a collection.
  """
  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a collection and all the stories in it.
  """
  def delete_collection(%Collection{} = collection) do
    stories_query =
      Story
      |> join(:inner, [..., s], cs in assoc(s, :collection_story))
      |> CollectionStory.by_collection(collection)

    Multi.new()
    |> Multi.delete(:collection, collection)
    |> Multi.delete_all(:stories, stories_query)
    |> Repo.transaction()
  end
end
