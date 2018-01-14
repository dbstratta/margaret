defmodule Margaret.Stories do
  @moduledoc """
  The Stories context.
  """

  alias Ecto.Multi

  alias Margaret.{Repo, Accounts, Stories, Publications, Tags}
  alias Accounts.User
  alias Stories.Story

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
  @spec get_story_by_unique_hash(String.t) :: Story.t | nil
  def get_story_by_unique_hash(unique_hash), do: Repo.get_by(Story, unique_hash: unique_hash)

  def get_title(%Story{content: %{"blocks" => [%{"text" => title} | _]}}) do
    title
  end

  def get_slug(%Story{unique_hash: unique_hash} = story) do
    story
    |> Stories.get_title()
    |> Slugger.slugify_downcase()
    |> Kernel.<>("-")
    |> Kernel.<>(unique_hash)
  end

  def has_been_published?(%Story{published_at: published_at}) do
    published_at <= NaiveDateTime.utc_now()
  end

  @doc """
  Returns `true` if the story is public,
  `false` otherwise.

  ## Examples

      iex> story_public?(%Story{})
      true

      iex> story_public?(123)
      false

      iex> story_public?(nil)
      false

  """
  @spec story_public?(Story.t) :: boolean
  def story_public?(%Story{audience: :all} = story), do: has_been_published?(story)

  def story_public?(_), do: false

  @doc """
  Returns `true` if the user can see the story.
  `false` otherwise.

  ## Examples

      iex> story_public?(%Story{})
      true

      iex> story_public?(123)
      false

      iex> story_public?(nil)
      false

  """
  @spec can_see_story?(Story.t, User.t) :: boolean
  def can_see_story?(%Story{author_id: author_id}, %User{id: author_id}), do: true

  def can_see_story?(
    %Story{publication_id: publication_id}, %User{id: user_id}
  ) when not is_nil(publication_id) do
    Publications.can_edit_stories?(publication_id, user_id)
  end

  def can_see_story?(%Story{audience: :members} = story, %User{} = user) do
    is_member = Accounts.member?(user)
    has_been_published = has_been_published?(story)

    is_member and has_been_published
  end

  def can_see_story?(%Story{} = story, _user), do: story_public?(story)

  @doc """
  Returns `true` if the user can update the story,
  `false` otherwise.
  """
  def can_update_story?(%Story{author_id: author_id}, %User{id: author_id}), do: true

  def can_update_story?(
    %Story{publication_id: publication_id}, %User{id: user_id}
  ) when not is_nil(publication_id) do
    Publications.can_edit_stories?(publication_id, user_id)
  end

  def can_update_story?(_, _), do: false

  def can_delete_story?(%Story{author_id: author_id}, %User{id: author_id}), do: true
  def can_delete_story?(_, _), do: false

  @doc """
  Inserts a story.
  """
  def insert_story(attrs), do: upsert_story(%Story{}, attrs)

  defp upsert_story(story, %{tags: tags} = attrs) do
    upsert_story_fn = fn %{tags: tag_structs} ->
      attrs_with_tags = Map.put(attrs, :tags, tag_structs)

      story
      |> Repo.preload(:tags)
      |> Story.changeset(attrs_with_tags)
      |> Repo.insert_or_update()
    end

    Multi.new()
    |> Multi.run(:tags, fn _ -> {:ok, Tags.insert_and_get_all_tags(tags)} end)
    |> Multi.run(:story, upsert_story_fn)
    |> Repo.transaction()
  end

  defp upsert_story(story, attrs) do
    story_changeset = Story.changeset(story, attrs)

    Multi.new()
    |> Multi.insert_or_update(:story, story_changeset)
    |> Repo.transaction()
  end

  @doc """
  Updates a story.
  """
  def update_story(%Story{} = story, attrs), do: upsert_story(story, attrs)

  @doc """
  Deletes a story.
  """
  def delete_story(%Story{} = story), do: Repo.delete(story)
end
