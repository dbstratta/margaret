defmodule Margaret.Stories do
  @moduledoc """
  The Stories context.
  """

  alias Ecto.Multi

  alias Margaret.{Repo, Stories, Tags}
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

  @spec get_story_by_unique_hash(String.t) :: Story.t | nil
  def get_story_by_unique_hash(unique_hash), do: Repo.get_by(Story, unique_hash: unique_hash)

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
