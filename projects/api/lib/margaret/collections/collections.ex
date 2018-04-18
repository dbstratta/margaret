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
  @spec get_collection(String.t() | non_neg_integer()) :: Collection.t() | nil
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

      iex> author(%Collection{})
      %User{}

  """
  @spec author(Collection.t()) :: User.t()
  def author(%Collection{} = collection) do
    collection
    |> Collection.preload_author()
    |> Map.get(:author)
  end

  @doc """
  Gets the publication of the collection.

  ## Examples

      iex> publication(%Collection{})
      %Publication{}

      iex> publication(%Collection{})
      nil

  """
  @spec publication(Collection.t()) :: Publication.t() | nil
  def publication(%Collection{} = collection) do
    collection
    |> Collection.preload_publication()
    |> Map.get(:publication)
  end

  @doc """
  Gets the tags of the collection.

  ## Examples

      iex> tags(%Collection{})
      [%Tag{}]

  """
  @spec tags(Collection.t()) :: [Tag.t()]
  def tags(%Collection{} = collection) do
    collection
    |> Collection.preload_tags()
    |> Map.get(:tags)
  end

  @doc """
  Returns the part of the story in the collection if its in any.
  `nil` otherwise.
  """
  @spec story_part(Story.t()) :: non_neg_integer() | nil
  def story_part(%Story{} = story) do
    case get_collection_story(story) do
      %CollectionStory{part: part} -> part
      nil -> nil
    end
  end

  @doc """
  Returns `true` if the story is in the collection.
  `false` otherwise.

  ## Examples

      iex> in_collection?(%Collection{}, %Story{})
      true

  """
  @spec in_collection?(Collection.t(), Story.t()) :: boolean()
  def in_collection?(%Collection{id: collection_id}, %Story{} = story) do
    case Stories.collection(story) do
      %Collection{id: story_collection_id} when story_collection_id === collection_id -> true
      _ -> false
    end
  end

  @doc """
  Returns `true` if the user can add stories to the collection.
  `false` otherwise.

  ## Examples

      iex> can_add_stories_to_collection?(%Collection{}, %User{})
      true

      iex> can_add_stories_to_collection?(%Collection{}, %User{})
      false

  """

  @spec can_add_stories_to_collection?(Collection.t(), User.t()) :: boolean()
  def can_add_stories_to_collection?(%Collection{author_id: user_id}, %User{id: user_id}),
    do: true

  def can_add_stories_to_collection?(_user, _collection), do: false

  @doc """
  Inserts a collection.
  """
  @spec insert_collection(map()) :: {:ok, Collection.t()} | {:error, Ecto.Changeset.t()}
  def insert_collection(attrs) do
    attrs
    |> Collection.changeset()
    |> Repo.insert()
  end

  @doc """
  Updates a collection.
  """
  @spec update_collection(Collection.t(), map()) ::
          {:ok, Collection.t()} | {:error, Ecto.Changeset.t()}
  def update_collection(%Collection{} = collection, attrs) do
    collection
    |> Collection.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  TODO: Implement changing the position of stories within a collection.
  """
  @spec move_story(Story.t(), pos_integer()) :: {:ok, Story.t()} | {:error, any()}
  def move_story(%Story{} = story, part) do
    story
    |> Stories.collection()
    |> do_move_story(story, part)
  end

  @spec do_move_story(Collection.t() | nil, Story.t(), pos_integer()) ::
          {:ok, Story.t()} | {:error, any()}
  defp do_move_story(nil, _story, _part), do: {:error, "Story isn't in a collection"}

  # defp do_move_story(%Collection{} = collection, %Story{id: story_id}, part) do
  #   update_query = CollectionStory.by_collection(collection)
  # end

  @doc """
  Deletes a collection and all the stories in it.
  """
  @spec delete_collection(Collection.t()) :: {:ok, Collection.t()} | {:error, Ecto.Changeset.t()}
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

  @doc """
  Gets the story count of a collection.

  ## Examples

      iex> story_count(%Collection{})
      2

  """
  @spec story_count(Collection.t()) :: non_neg_integer()
  def story_count(%Collection{} = collection) do
    collection
    |> CollectionStory.by_collection(collection)
    |> Repo.aggregate(:count, :id)
  end

  @doc """
  Gets the part number of the next story of the collection.

  ## Examples

      iex> next_part_number(%Collection{})
      3

  """
  @spec next_part_number(Collection.t()) :: pos_integer()
  def next_part_number(%Collection{} = collection), do: story_count(collection) + 1

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
