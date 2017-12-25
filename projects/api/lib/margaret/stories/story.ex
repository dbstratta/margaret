defmodule Margaret.Stories.Story do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Stars, Comments, Publications, Tags}
  alias Accounts.User
  alias Stars.Star
  alias Comments.Comment
  alias Publications.Publication
  alias Tags.Tag

  @type t :: %Story{}

  schema "stories" do
    field :title, :string
    field :body, :string
    belongs_to :author, User
    field :summary, :string
    field :unique_hash, :string
    field :published_at, :naive_datetime
    has_many :stars, Star
    has_many :comments, Comment
    belongs_to :publication, Publication
    many_to_many :tags, Tag, join_through: "story_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(%Story{} = story, %{tags: tags} = attrs) do
    story
    |> cast(attrs, [:title, :body, :author_id, :publication_id, :published_at, :summary])
    |> validate_required([:title, :body, :author_id])
    |> put_assoc(:tags, tags)
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:publication_id)
    |> maybe_put_unique_hash()
  end

  defp maybe_put_unique_hash(%Ecto.Changeset{data: %{unique_hash: nil}} = changeset) do
    put_change(changeset, :unique_hash, generate_hash())
  end

  defp maybe_put_unique_hash(changeset), do: changeset

  defp generate_hash() do
    :sha512
    |> :crypto.hash(UUID.uuid4())
    |> Base.encode32()
    |> String.slice(0..16)
    |> String.downcase()
  end
end