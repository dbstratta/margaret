defmodule Margaret.Stories do
  @moduledoc """
  The Stories context.
  """

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Publications,
    Collections,
    RichEditor,
    Helpers
  }

  alias Accounts.User
  alias Stories.Story
  alias Publications.Publication
  alias Collections.Collection

  @doc """
  Gets a single story by its id.

  ## Examples

      iex> get_story(123)
      %Story{}

      iex> get_story(456)
      nil

  """
  @spec get_story(String.t() | non_neg_integer()) :: Story.t() | nil
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
  @spec get_story!(String.t() | non_neg_integer()) :: Story.t() | no_return()
  def get_story!(id), do: Repo.get!(Story, id)

  @doc """
  Gets a story by its slug.

  ## Examples

      iex> get_story_by_slug("slug-234abfe")
      %Story{}

      iex> get_story_by_slug("slug-456a3be")
      nil

  """
  @spec get_story_by_slug(String.t()) :: Story.t() | nil
  def get_story_by_slug(slug) do
    slug
    |> String.split("-")
    |> List.last()
    |> get_story_by_unique_hash()
  end

  @doc """
  Gets a story by its unique_hash.

  ## Examples

      iex> get_story_by_unique_hash("a324b897c")
      %Story{}

      iex> get_story_by_unique_hash("jksdf234")
      nil

  """
  @spec get_story_by_unique_hash(String.t()) :: Story.t() | nil
  def get_story_by_unique_hash(unique_hash),
    do: Repo.get_by(Story, unique_hash: unique_hash)

  @doc """
  Gets the title of a story.

  ## Examples

      iex> title(%Story{})
      "Title"

  """
  @spec title(Story.t()) :: String.t()
  def title(%Story{content: content}),
    do: RichEditor.DraftJS.title(content)

  @doc """
  Gets the slug of a story.

  ## Examples

      iex> slug(%Story{})
      "title-abc123ba"

  """
  @spec slug(Story.t()) :: String.t()
  def slug(%Story{unique_hash: unique_hash} = story) do
    story
    |> title()
    |> Slugger.slugify_downcase()
    |> Kernel.<>("-")
    |> Kernel.<>(unique_hash)
  end

  @doc """
  Gets the summary of a story.

  ## Examples

      iex> summary(%Story{})
      "Lorem ipsum."

      iex> summary(%Story{})
      ""

  """
  @spec summary(Story.t()) :: String.t()
  def summary(%Story{content: content}),
    do: RichEditor.DraftJS.summary(content)

  @doc """
  Gets the author of a story.

  ## Examples

      iex> author(%Story{})
      %User{}

  """
  @spec author(Story.t()) :: User.t()
  def author(%Story{} = story) do
    story
    |> Story.preload_author()
    |> Map.fetch!(:author)
  end

  @doc """
  Gets the tags of a story.

  ## Examples

      iex> tags(%Story{})
      [%Tag{}]

  """
  @spec tags(Story.t()) :: [Tag.t()]
  def tags(%Story{} = story) do
    story
    |> Story.preload_tags()
    |> Map.get(:tags)
  end

  @doc """
  Gets the publication of a story.

  ## Examples

      iex> publication(%Story{})
      %Publication{}

      iex> publication(%Story{})
      nil

  """
  @spec publication(Story.t()) :: Publication.t() | nil
  def publication(%Story{} = story) do
    story
    |> Story.preload_publication()
    |> Map.fetch!(:publication)
  end

  @doc """
  Gets the collection of a story.

  ## Examples

      iex> collection(%Story{})
      %Collection{}

      iex> collection(%Story{})
      nil

  """
  @spec collection(Story.t()) :: Collection.t() | nil
  def collection(%Story{} = story) do
    story
    |> Story.preload_collection()
    |> Map.fetch!(:collection)
  end

  @doc """
  Gets the word count of a story.

  ## Examples

      iex> word_count(%Story{})
      42

  """
  @spec word_count(Story.t()) :: non_neg_integer()
  def word_count(%Story{content: content}) do
    RichEditor.DraftJS.word_count(content)
  end

  @doc """
  Gets the read time of a story in minutes.

  ## Examples

      iex> read_time(%Story{})
      12

  """
  @spec read_time(Story.t()) :: non_neg_integer()
  def read_time(%Story{} = story) do
    avg_word_per_minute = 275

    story
    |> word_count()
    |> div(avg_word_per_minute)
    |> case do
      0 -> 1
      read_time -> read_time
    end
  end

  @doc """
  Returns `true` if the story is under a publication.
  """
  @spec under_publication?(Story.t()) :: boolean()
  def under_publication?(%Story{publication_id: nil}), do: false
  def under_publication?(%Story{}), do: true

  @doc """
  Returns `true` if the story is in a collection.
  """
  @spec in_collection?(Story.t()) :: boolean()
  def in_collection?(%Story{} = story), do: !!collection(story)

  @doc """
  Returns `true` if the story has been published.
  `false` otherwise.

  ## Examples

      iex> has_been_published(%Story{})
      false

  """
  @spec has_been_published?(Story.t()) :: boolean()
  def has_been_published?(%Story{published_at: nil}), do: false

  def has_been_published?(%Story{published_at: published_at}),
    do: NaiveDateTime.compare(published_at, NaiveDateTime.utc_now()) === :lt

  @doc """
  Returns `true` if the story is public,
  `false` otherwise.

  Public means that the story is visible by anyone.

  ## Examples

      iex> public?(%Story{})
      true

      iex> public?(%Story{})
      false

  """
  @spec public?(Story.t()) :: boolean()
  def public?(%Story{audience: :all} = story), do: has_been_published?(story)
  def public?(_), do: false

  @doc """
  Returns `true` if the user can see the story.
  `false` otherwise.

  ## Examples

      iex> can_see_story?(%Story{}, %User{})
      true

  """
  @spec can_see_story?(Story.t(), User.t()) :: boolean()
  def can_see_story?(%Story{author_id: author_id}, %User{id: author_id}), do: true

  def can_see_story?(%Story{publication_id: publication_id}, %User{} = user)
      when not is_nil(publication_id) do
    publication_id
    |> Publications.get_publication()
    |> Publications.can_edit_stories?(user)
  end

  def can_see_story?(%Story{audience: :members} = story, %User{} = user) do
    is_member = Accounts.member?(user)
    has_been_published = has_been_published?(story)

    is_member and has_been_published
  end

  def can_see_story?(%Story{} = story, _user), do: public?(story)

  @doc """
  Returns `true` if the user can update the story,
  `false` otherwise.

  ## Examples

      iex> can_update_story?(%Story{}, %User{})
      true

  """
  @spec can_update_story?(Story.t(), User.t()) :: boolean()
  def can_update_story?(%Story{author_id: author_id}, %User{id: author_id}), do: true

  def can_update_story?(%Story{publication_id: publication_id}, %User{id: user_id})
      when not is_nil(publication_id) do
    Publications.can_edit_stories?(publication_id, user_id)
  end

  def can_update_story?(_, _), do: false

  @doc """
  """
  @spec stories(map()) :: any()
  def stories(args) do
    args
    |> Stories.Queries.stories()
    |> Helpers.Connection.from_query(args)
  end

  @doc """
  """
  @spec story_count(map()) :: non_neg_integer()
  def story_count(args \\ %{}) do
    args
    |> Stories.Queries.stories()
    |> Repo.count()
  end

  @doc """
  Deletes a story.

  ## Examples

      iex> delete_story(%Story{})
      {:ok, %Story{}}

  """
  @spec delete_story(Story.t()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
  def delete_story(%Story{} = story), do: Repo.delete(story)
end
