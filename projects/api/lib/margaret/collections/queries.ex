defmodule Margaret.Collections.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{
    Stories,
    CollectionStories
  }

  alias Stories.Story
  alias CollectionStories.CollectionStory

  @doc """
  """
  def collection_stories(%{collection_id: collection_id} = _args) do
    from cs in CollectionStory,
      where: cs.collection_id == ^collection_id
  end

  def stories(%{collection_id: collection_id} = _args) do
    from s in Story,
      join: cs in assoc(s, :collection_story),
      where: cs.collection_id == ^collection_id
  end
end
