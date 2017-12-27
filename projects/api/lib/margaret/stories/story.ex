defmodule Margaret.Stories.Story do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__
  alias Margaret.{Accounts, Stars, Comments, Publications, Tags}
  alias Accounts.User
  alias Stars.Star
  alias Comments.Comment
  alias Publications.Publication
  alias Tags.Tag

  @type t :: %Story{}

  @permitted_attrs [
    :title,
    :body,
    :author_id,
    :summary,
    :publication_id,
    :published_at,
    :publish_status,
    :license,
  ]

  @required_attrs [
    :title,
    :body,
    :author_id,
    :publish_status,
  ]

  defenum StoryPublishStatus,
    :story_publish_status,
    [:public, :draft, :unlisted]

  defenum StoryLicense,
    :story_license,
    [:all_rights_reserved, :public_domain]

  schema "stories" do
    field :title, :string
    field :body, :string
    belongs_to :author, User
    field :summary, :string
    field :unique_hash, :string

    field :published_at, :naive_datetime
    field :publish_status, StoryPublishStatus
    field :license, StoryLicense

    has_many :stars, Star
    has_many :comments, Comment
    belongs_to :publication, Publication
    many_to_many :tags, Tag, join_through: "story_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(%Story{} = story, %{tags: tags} = attrs) do
    story
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
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