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
  
  @unique_hash_length 16

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
  def changeset(%Story{} = story, attrs) do
    story
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:author_id)
    |> foreign_key_constraint(:publication_id)
    |> maybe_put_tags()
    |> maybe_put_unique_hash()
    |> maybe_put_published_at()
  end

  defp maybe_put_tags(%Ecto.Changeset{changes: %{tags: tags}} = changeset) do
    put_assoc(changeset, :tags, tags)
  end

  defp maybe_put_tags(changeset), do: changeset

  defp maybe_put_unique_hash(%Ecto.Changeset{data: %{unique_hash: nil}} = changeset) do
    put_change(changeset, :unique_hash, generate_hash())
  end

  defp maybe_put_unique_hash(changeset), do: changeset

  defp generate_hash() do
    :sha512
    |> :crypto.hash(UUID.uuid4())
    |> Base.encode32()
    |> String.slice(0..@unique_hash_length)
    |> String.downcase()
  end

  # Only put the `published_at` attribute when the story
  # hasn't been published before and the change is to make it public.
  defp maybe_put_published_at(
    %Ecto.Changeset{
      data: %{published_at: nil}, changes: %{publish_status: publish_status}
    } = changeset
  ) when publish_status === :public do
    put_change(changeset, :published_at, NaiveDateTime.utc_now())
  end

  defp maybe_put_published_at(changeset), do: changeset
end
