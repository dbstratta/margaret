defmodule Margaret.Collections.Collection do
  @moduledoc """
  The Collection schema and changesets.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Stories.Story,
    Collections.CollectionStory,
    Publications.Publication,
    Tags.Tag,
    Helpers
  }

  @type t :: %Collection{}

  schema "collections" do
    field(:title, :string)

    field(:image, :string)
    field(:subtitle, :string)
    field(:description, :string)

    field(:slug, :string)

    belongs_to(:author, User)

    has_many(:collection_stories, CollectionStory)
    many_to_many(:stories, Story, join_through: CollectionStory)

    # Collections can be published under a publication.
    belongs_to(:publication, Publication)

    many_to_many(:tags, Tag, join_through: "collection_tags", on_replace: :delete)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a collection.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      title
      subtitle
      description
      slug
      author_id
      publication_id
    )a

    required_attrs = ~w(
      title
      subtitle
      author_id
    )a

    %Collection{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:author)
    |> assoc_constraint(:publication)
    |> Helpers.maybe_put_tags_assoc(attrs)
  end

  @doc """
  Builds a changeset for updating a collection.
  """
  def update_changeset(%Collection{} = collection, attrs) do
    permitted_attrs = ~w(
      title
      subtitle
      description
      slug
      publication_id
    )a

    collection
    |> cast(attrs, permitted_attrs)
    |> assoc_constraint(:publication)
    |> Helpers.maybe_put_tags_assoc(attrs)
  end

  @doc """
  Filters the collections by author.
  """
  @spec by_author(Ecto.Query.t(), User.t()) :: Ecto.Query.t()
  def by_author(query \\ Collection, %User{id: author_id}),
    do: where(query, [..., c], c.author_id == ^author_id)

  @doc """
  Filters the collections in the query by being under a publication.
  """
  @spec under_publication(Ecto.Query.t(), Publication.t()) :: Ecto.Query.t()
  def under_publication(query \\ Collection, %Publication{id: publication_id}),
    do: where(query, [..., c], c.publication_id == ^publication_id)

  @doc """
  Preloads the author of a collection.
  """
  @spec preload_author(t) :: t
  def preload_author(%Collection{} = collection), do: Repo.preload(collection, :author)

  @doc """
  Preloads the publication of a collection.
  """
  @spec preload_publication(t) :: t
  def preload_publication(%Collection{} = collection), do: Repo.preload(collection, :publication)

  @doc """
  Preloads the tags of a collection.
  """
  @spec preload_tags(t) :: t
  def preload_tags(%Collection{} = collection), do: Repo.preload(collection, :tags)
end
