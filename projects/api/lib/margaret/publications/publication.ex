defmodule Margaret.Publications.Publication do
  @moduledoc """
  The Publication schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Publications.PublicationMembership,
    Follows.Follow,
    Tags.Tag,
    Helpers
  }

  @type t :: %Publication{}

  schema "publications" do
    field(:name, :string)
    field(:display_name, :string)

    field(:description, :string)
    field(:website, :string)

    has_many(:publication_memberships, PublicationMembership)
    many_to_many(:members, User, join_through: PublicationMembership)

    many_to_many(
      :followers,
      User,
      join_through: Follow,
      join_keys: [publication_id: :id, follower_id: :id]
    )

    many_to_many(:tags, Tag, join_through: "publication_tags", on_replace: :delete)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a publication.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      name
      display_name
      description
      website
    )a

    required_attrs = ~w(
      display_name
    )a

    %Publication{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> maybe_put_name()
    |> validate_length(:name, min: 2, max: 64)
    |> unique_constraint(:name)
    |> Helpers.maybe_put_tags_assoc(attrs)
  end

  @doc """
  Builds a changeset for updating a publication.
  """
  def update_changeset(%Publication{} = publication, attrs) do
    update_permitted_attrs = ~w(
      name
      display_name
      description
      website
    )a

    publication
    |> cast(attrs, update_permitted_attrs)
    |> maybe_put_name()
    |> validate_length(:name, min: 2, max: 64)
    |> unique_constraint(:name)
    |> Helpers.maybe_put_tags_assoc(attrs)
  end

  # TODO: Refactor this function using `get_field/3`.
  defp maybe_put_name(%Ecto.Changeset{changes: %{name: name}} = changeset) when not is_nil(name) do
    put_change(changeset, :name, name)
  end

  defp maybe_put_name(
         %Ecto.Changeset{data: %{name: nil}, changes: %{display_name: display_name}} = changeset
       ) do
    put_change(changeset, :name, Slugger.slugify_downcase(display_name))
  end

  defp maybe_put_name(changeset), do: changeset

  @doc """
  Preloads the tags of a publication.
  """
  @spec preload_tags(t) :: t
  def preload_tags(%Publication{} = publication), do: Repo.preload(publication, :tags)
end
