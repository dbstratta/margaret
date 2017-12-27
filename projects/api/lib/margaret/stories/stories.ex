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

  @spec get_story_by_unique_hash(String.t) :: Story.t | nil
  def get_story_by_unique_hash(unique_hash), do: Repo.get_by(Story, unique_hash: unique_hash)

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
  ) do
    cond do
      Publications.is_publication_editor?(publication_id, user_id) -> true
      Publications.is_publication_admin?(publication_id, user_id) -> true
      true -> false
    end
  end

  @doc """
  Inserts a story.
  """
  def insert_story(%{tags: tags} = attrs) do
    Multi.new()
    |> Multi.run(:tags, fn _ -> {:ok, Tags.insert_and_get_all_tags(tags)} end)
    |> Multi.run(:story, &do_insert_story(attrs, &1))
    |> Repo.transaction()
  end

  def insert_story(attrs), do: insert_story(Map.put(attrs, :tags, []))

  defp do_insert_story(attrs, %{tags: tags}) do
    attrs_with_tags = Map.put(attrs, :tags, tags)

    %Story{}
    |> Story.changeset(attrs_with_tags)
    |> Repo.insert_or_update()
  end

  @doc """
  Updates a story.
  """
  def update_story(story_id, attrs) do


    # Multi.new()
    # |> Multi.run(:tags, fn %{old_story: old_t} -> {:ok, Tags.insert_and_get_all_tags(tags)} end)
    # upsert_story(story, attrs)
  end

  @doc """
  Deletes a story.
  """
  def delete_story(id) do
    Repo.delete(%Story{id: id})
  end
end
