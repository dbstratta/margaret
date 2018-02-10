defmodule Margaret.Tags.Tag do
  @moduledoc """
  The Tag schema and changesets.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias __MODULE__

  alias Margaret.{
    Stories.Story,
    Publications.Publication
  }

  @type t :: %Tag{}

  schema "tags" do
    # The text of the tag.
    field(:title, :string)

    many_to_many(:collections, Publication, join_through: "collection_tags")
    many_to_many(:stories, Story, join_through: "story_tags")
    many_to_many(:publications, Publication, join_through: "publication_tags")

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a tag.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      title
    )a

    required_attrs = ~w(
      title
    )a

    %Tag{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> unique_constraint(:title)
  end

  @doc """
  Filters the tags in the query by a title list.
  """
  @spec by_titles(Ecto.Query.t(), [String.t()]) :: Ecto.Query.t()
  def by_titles(query \\ Tag, titles), do: where(query, [..., t], t.title in ^titles)
end
