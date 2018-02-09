defmodule Margaret.Stories.Story do
  @moduledoc """
  The Story schema and changesets.

  TODO: In the future, it would be a good idea to validate
  the format of the `content` field.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Stories.StoryView,
    Stars.Star,
    Comments.Comment,
    Publications.Publication,
    Collections.CollectionStory,
    Tags.Tag,
    Helpers
  }

  @type t :: %Story{}

  defenum StoryAudience, :story_audience, [:all, :members, :unlisted]
  defenum StoryLicense, :story_license, [:all_rights_reserved, :public_domain]

  schema "stories" do
    # `content` is rich text and contains metadata, so we store it as a map.
    field(:content, :map)
    belongs_to(:author, User)

    # We use a unique hash to identify the story in a slug.
    field(:unique_hash, :string)

    field(:audience, StoryAudience)
    field(:published_at, :naive_datetime)

    field(:license, StoryLicense)

    has_many(:stars, Star)
    has_many(:comments, Comment)
    # A view refers to a user viewing (reading) the story.
    has_many(:views, StoryView)

    # Stories can be published under a publication.
    belongs_to(:publication, Publication)

    has_one(:collection_story, CollectionStory)
    has_one(:collection, through: [:collection_story, :collection])

    many_to_many(:tags, Tag, join_through: "story_tags", on_replace: :delete)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a story.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      content
      author_id
      audience
      publication_id
      published_at
      license
    )a

    required_attrs = ~w(
      content
      author_id
      audience
      license
    )a

    %Story{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:author)
    |> assoc_constraint(:publication)
    |> Helpers.maybe_put_tags_assoc(attrs)
    |> maybe_put_unique_hash()
  end

  @doc """
  Builds a changeset for updating a story.
  """
  def update_changeset(%Story{} = story, attrs) do
    permitted_attrs = ~w(
      content
      audience
      publication_id
      published_at
      license
    )a

    story
    |> cast(attrs, permitted_attrs)
    |> assoc_constraint(:publication)
    |> Helpers.maybe_put_tags_assoc(attrs)
  end

  # Only put `unique_hash` in the changeset if the story is being created.
  defp maybe_put_unique_hash(%Ecto.Changeset{data: %{unique_hash: nil}} = changeset) do
    put_change(changeset, :unique_hash, generate_hash())
  end

  defp maybe_put_unique_hash(changeset), do: changeset

  # Generates a unique hash for a story.
  defp generate_hash do
    unique_hash_length = 16

    # I think this is enough to guarantee uniqueness.
    :sha512
    |> :crypto.hash(UUID.uuid4())
    |> Base.encode32()
    |> String.slice(0..unique_hash_length)
    |> String.downcase()
  end

  @doc """
  Filters the stories in the query by published.
  """
  @spec published(Ecto.Query.t()) :: Ecto.Query.t()
  def published(query \\ Story),
    do: where(query, [..., s], s.published_at <= ^NaiveDateTime.utc_now())

  @doc """
  Filters the stories in the query by scheduled.
  """
  @spec scheduled(Ecto.Query.t()) :: Ecto.Query.t()
  def scheduled(query \\ Story),
    do: where(query, [..., s], s.published_at > ^NaiveDateTime.utc_now())

  @doc """
  """
  @spec public(Ecto.Query.t()) :: Ecto.Query.t()
  def public(query \\ Story) do
    query
    |> published()
    |> where([..., s], s.audience == ^:all)
  end

  @doc """
  Filters the stories by author.
  """
  @spec by_author(Ecto.Query.t(), User.t()) :: Ecto.Query.t()
  def by_author(query \\ Story, %User{id: author_id}),
    do: where(query, [..., s], s.author_id == ^author_id)

  @doc """
  Filters the stories in the query by being under a publication.
  """
  @spec under_publication(Ecto.Query.t(), Publication.t()) :: Ecto.Query.t()
  def under_publication(query \\ Story, %Publication{id: publication_id}),
    do: where(query, [..., s], s.publication_id == ^publication_id)

  @doc """
  Preloads the author of a story.
  """
  @spec preload_author(t) :: t
  def preload_author(%Story{} = story), do: Repo.preload(story, :author)

  @doc """
  Preloads the publication of a story.
  """
  @spec preload_publication(t) :: t
  def preload_publication(%Story{} = story), do: Repo.preload(story, :publication)

  @doc """
  Preloads the collection of a story.
  """
  @spec preload_collection(t) :: t
  def preload_collection(%Story{} = story), do: Repo.preload(story, :collection)

  @doc """
  Preloads the tags of a story.
  """
  @spec preload_tags(t) :: t
  def preload_tags(%Story{} = story), do: Repo.preload(story, :tags)
end
