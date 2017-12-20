defmodule Margaret.Stories.Story.TitleSlug do
  @moduledoc """
  Implementation module of EctoAutoslugField.
  """

  use EctoAutoslugField.Slug, from: :title, to: :slug

  @doc """
  Generates a hash from a uuid4.
  """
  def generate_hash() do
    :sha512
    |> :crypto.hash(UUID.uuid4())
    |> Base.encode32()
    |> String.slice(0..12)
    |> String.downcase()
  end

  @doc """
  Builds the slug before inserting it into the DB.
  """
  def build_slug(sources, changeset) do
    sources
    |> super(changeset)
    |> Kernel.<>("--#{generate_hash()}")
  end
end

defmodule Margaret.Stories.Story do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Stars, Comments, Publications}
  alias Accounts.User
  alias Stars.Star
  alias Comments.Comment
  alias Publications.Publication
  alias Story.TitleSlug

  @typedoc "The Story type"
  @type t :: %Story{}

  schema "stories" do
    field :title, :string
    field :body, :string
    belongs_to :author, User
    field :summary, :string
    field :slug, TitleSlug.Type
    field :published_at, :naive_datetime
    has_many :stars, Star
    has_many :comments, Comment
    belongs_to :publication, Publication

    timestamps()
  end

  @doc false
  def changeset(%Story{} = story, attrs) do
    story
    |> cast(attrs, [:title, :body, :author_id, :publication_id, :published_at, :summary])
    |> validate_required([:title, :body, :author_id])
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:publication_id)
    |> TitleSlug.maybe_generate_slug()
    |> TitleSlug.unique_constraint()
  end

  @doc false
  def update_changeset(%Story{} = story, attrs) do
    story
    |> cast(attrs, [:title, :body, :publication_id, :published_at, :summary])
    |> validate_required([:title, :body])
    |> foreign_key_constraint(:publication_id)
  end
end