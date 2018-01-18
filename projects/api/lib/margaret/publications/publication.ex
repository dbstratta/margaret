defmodule Margaret.Publications.Publication do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Publications, Tags}
  alias Accounts.{User, Follow}
  alias Publications.PublicationMembership
  alias Tags.Tag

  @type t :: %Publication{}

  @permitted_attrs [
    :name,
    :display_name,
  ]

  @required_attrs [
    :display_name,
  ]

  @update_permitted_attrs [
    :name,
    :display_name,
  ]

  @update_required_attrs []

  schema "publications" do
    field :name, :string
    field :display_name, :string

    many_to_many :members, User, join_through: PublicationMembership

    many_to_many :followers, User,
      join_through: Follow,
      join_keys: [publication_id: :id, follower_id: :id]

    many_to_many :tags, Tag, join_through: "publication_tags", on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(attrs), do: changeset(%Publication{}, attrs)

  @doc false
  def changeset(%Publication{} = publication, attrs) do
    publication
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> maybe_put_name()
    |> maybe_put_tags(attrs)
    |> validate_length(:name, min: 2, max: 64)
    |> unique_constraint(:name)
  end

  @doc false
  def update_changeset(%Publication{} = publication, attrs) do
    publication
    |> cast(attrs, @update_permitted_attrs)
    |> validate_required(@update_required_attrs)
    |> maybe_put_name()
    |> maybe_put_tags(attrs)
    |> validate_length(:name, min: 2, max: 64)
    |> unique_constraint(:name)
  end

  defp maybe_put_tags(%Ecto.Changeset{} = changeset, %{tags: tags} = attrs) do
    put_assoc(changeset, :tags, tags)
  end

  defp maybe_put_tags(%Ecto.Changeset{} = changeset, _attrs), do: changeset

  defp maybe_put_name(%Ecto.Changeset{changes: %{name: name}} = changeset) when not is_nil(name) do
    put_change(changeset, :name, name)
  end

  defp maybe_put_name(
    %Ecto.Changeset{data: %{name: nil}, changes: %{display_name: display_name}} = changeset
  ) do
    put_change(changeset, :name, Slugger.slugify_downcase(display_name))
  end

  defp maybe_put_name(changeset), do: changeset
end
