defmodule Margaret.Tags.Tag do
  @moduledoc """
  The Tag schema and changesets.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias __MODULE__

  alias Margaret.{
    Stories.Story,
    Publications.Publication,
    Collections.Collection
  }

  @type t :: %Tag{}

  schema "tags" do
    # The text of the tag.
    field(:title, :string)

    many_to_many(:collections, Collection, join_through: "collection_tags")
    many_to_many(:stories, Story, join_through: "story_tags")
    many_to_many(:publications, Publication, join_through: "publication_tags")

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a tag.
  """
  @spec changeset(map()) :: Ecto.Changeset.t()
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
  @spec by_titles(Ecto.Queryable.t(), [String.t()]) :: Ecto.Query.t()
  def by_titles(query \\ Tag, titles), do: where(query, [..., t], t.title in ^titles)
end

defimpl String.Chars, for: Margaret.Tags.Tag do
  alias Margaret.Tags.Tag

  def to_string(%Tag{title: title}), do: title
end
