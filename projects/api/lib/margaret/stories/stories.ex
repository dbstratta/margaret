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

  @doc """
  Returns `{true, %Story{}}` if the story is public,
  `{false, %Story{}}` otherwise.

  ## Examples

      iex> is_story_public?(%Story{})
      {true, %Story{}}

      iex> is_story_public?(123)
      {false, %Story{}}

      iex> is_story_public?(nil)
      {false, nil}

  """
  @spec is_story_public?(Story.t) :: {boolean, Story.t}
  def is_story_public?(%Story{publish_status: :public} = story), do: {true, story}

  def is_story_public?(%Story{} = story), do: {false, story}

  @spec is_story_public?(nil) :: {false, nil}
  def is_story_public?(nil), do: {false, nil}

  @spec is_story_public?(String.t | non_neg_integer) :: {boolean, Story.t | nil}
  def is_story_public?(story_id) when is_integer(story_id) or is_binary(story_id) do
    story_id
    |> get_story()
    |> is_story_public?()
  end

  @doc """
  Returns `{true, %Story{}}` if the user can see the story.
  `{false, %Story{}}` otherwise.

  ## Examples

      iex> is_story_public?(%Story{})
      {true, %Story{}}

      iex> is_story_public?(123)
      {false, %Story{}}

      iex> is_story_public?(nil)
      {false, nil}

  """
  @spec can_see_story?(Story.t, User.t) :: {boolean, Story.t}
  def can_see_story?(
    %Story{author_id: author_id} = story, %User{id: user_id}
  ) when author_id === user_id do
    {true, story}
  end

  def can_see_story?(%Story{publish_status: :public} = story, _user), do: {true, story}

  def can_see_story?(
    %Story{publication_id: publication_id} = story, %User{id: user_id}
  ) when not is_nil(publication_id) do
    {Publications.can_edit_stories?(publication_id, user_id), story}
  end

  def can_see_story?(story, user) when is_nil(story) or is_nil(user), do: {false, nil}

  def can_see_story?(story_id, user) when is_integer(story_id) or is_binary(story_id) do
    can_see_story?(get_story(story_id), user)
  end

  def can_see_story?(story, user_id) when is_integer(user_id) or is_binary(user_id) do
    can_see_story?(story, Accounts.get_user(user_id))
  end

  @doc """
  Returns `true` if the user can update the story,
  `false` otherwise.
  """
  def can_user_update_story?(
    %Story{author_id: author_id}, %User{id: user_id}
  ) when author_id === user_id do
    true
  end

  def can_user_update_story?(
    %Story{author_id: author_id, publication_id: nil}, %User{id: user_id}
  ) when author_id !== user_id do
    false
  end

  def can_user_update_story?(
    %Story{publication_id: publication_id}, %User{id: user_id}
  ) when not is_nil(publication_id) do
    Publications.can_edit_stories?(publication_id, user_id)
  end

  def can_user_update_story?(story, user) when is_nil(story) or is_nil(user) do
    false
  end

  def can_user_update_story?(story_id, user) when is_binary(story_id) or is_integer(story_id) do
    can_user_update_story?(get_story(story_id), user)
  end

  def can_user_update_story?(story, user_id) when is_binary(user_id) or is_integer(user_id) do
    can_user_update_story?(story, Accounts.get_user(user_id))
  end

  @doc """
  Inserts a story.
  """
  def insert_story(attrs) do
    upsert_story(%Story{}, attrs)
  end

  defp upsert_story(story, %{tags: tags} = attrs) do
    Multi.new()
    |> Multi.run(:tags, fn _ -> {:ok, Tags.insert_and_get_all_tags(tags)} end)
    |> Multi.run(:story, &do_upsert_story(story, attrs, &1))
    |> Repo.transaction()
  end

  defp upsert_story(story, attrs) do
    story
    |> Story.changeset(attrs)
    |> Repo.insert_or_update()
  end


  defp do_upsert_story(story, attrs, %{tags: tags}) do
    attrs_with_tags = Map.put(attrs, :tags, tags)

    story
    |> Story.changeset(attrs_with_tags)
    |> Repo.insert_or_update()
  end

  @doc """
  Updates a story.
  """
  def update_story(%Story{} = story, attrs) do
    upsert_story(story, attrs)
  end

  def update_story(story_id, attrs) when is_integer(story_id) or is_binary(story_id) do
    story_id
    |> get_story()
    |> upsert_story(attrs)
  end

  @doc """
  Deletes a story.
  """
  def delete_story(id) do
    Repo.delete(%Story{id: id})
  end
end
