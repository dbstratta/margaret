defmodule Margaret.Stories.Story do
  @moduledoc false

  defmodule Slug do
    @moduledoc """
    Implementation module of EctoAutoslugField.
    """

    use EctoAutoslugField.Slug, from: :title, to: :slug

    def generate_hash() do
      "hash3000"
    end

    def build_slug(sources, changeset) do
      sources
      |> super(changeset)
      |> Kernel.<>("-#{generate_hash()}")
    end
  end

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__, as: Story
  alias Margaret.{Accounts, Stars, Comments, Publications}
  alias Accounts.User
  alias Stars.Star
  alias Comments.Comment
  alias Publications.Publication

  @typedoc "The Story type"
  @type t :: %Story{}

  schema "stories" do
    field :title, :string
    field :body, :string
    belongs_to :author, User
    field :summary, :string
    field :slug, Slug.Type
    field :published, :boolean
    field :published_at, :datetime
    has_many :stars, Star
    has_many :comments, Comment
    belongs_to :publication, Publication

    timestamps()
  end

  @doc false
  def changeset(%Story{} = story, attrs) do
    story
    |> cast(attrs, [:title, :body, :author_id, :publication_id, :published, :summary])
    |> validate_required([:title, :body, :author_id])
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:publication_id)
    |> Slug.maybe_generate_slug()
    |> Slug.unique_constraint()
  end

end
