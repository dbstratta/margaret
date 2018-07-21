defmodule Margaret.Collections.Collection do
  @moduledoc """
  The Collection schema and changesets.
  """

  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Stories.Story,
    CollectionStories.CollectionStory,
    Publications.Publication,
    Tags.Tag,
    Helpers
  }

  @type t :: %Collection{}

  schema "collections" do
    field(:title, :string)

    field(:cover, Collection.Cover.Type)
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
  @spec changeset(map()) :: Ecto.Changeset.t()
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
    |> cast_attachments(attrs, [:cover])
    |> validate_required(required_attrs)
    |> assoc_constraint(:author)
    |> assoc_constraint(:publication)
    |> Helpers.maybe_put_tags_assoc(attrs)
  end

  @doc """
  Builds a changeset for updating a collection.
  """
  @spec update_changeset(Collection.t(), map()) :: Ecto.Changeset.t()
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
    |> cast_attachments(attrs, [:cover])
    |> assoc_constraint(:publication)
    |> Helpers.maybe_put_tags_assoc(attrs)
  end

  @doc """
  Preloads the author of a collection.
  """
  @spec preload_author(t()) :: t()
  def preload_author(%Collection{} = collection), do: Repo.preload(collection, :author)

  @doc """
  Preloads the publication of a collection.
  """
  @spec preload_publication(t()) :: t()
  def preload_publication(%Collection{} = collection), do: Repo.preload(collection, :publication)

  @doc """
  Preloads the tags of a collection.
  """
  @spec preload_tags(t()) :: t()
  def preload_tags(%Collection{} = collection), do: Repo.preload(collection, :tags)
end
