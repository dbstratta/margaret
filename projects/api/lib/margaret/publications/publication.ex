defmodule Margaret.Publications.Publication do
  @moduledoc """
  The Publication schema and changesets.
  """

  use Ecto.Schema
  use Arc.Ecto.Schema
  import Ecto.{Changeset, Query}

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Stories.Story,
    Publications.PublicationMembership,
    Follows.Follow,
    Tags.Tag,
    Helpers
  }

  @type t :: %Publication{}

  @name_regex ~r/^[a-z\d](?:[a-z\d]|-(?=[a-z\d])){1,64}$/

  schema "publications" do
    # The name is the slug of the publication.
    field(:name, :string)
    field(:display_name, :string)

    field(:logo, Publication.Logo.Type)
    field(:description, :string)

    # Contact and social information.
    field(:email, :string)
    field(:website, :string)
    field(:twitter_username, :string)
    field(:facebook_pagename, :string)

    has_many(:stories, Story)

    has_many(:publication_memberships, PublicationMembership)
    many_to_many(:members, User, join_through: PublicationMembership)

    # A publication can have followers.
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

  ## Examples

      iex> changeset(attrs)
      %Ecto.Changeset{}

  """
  @spec changeset(map()) :: Ecto.Changeset.t()
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
    |> cast_attachments(attrs, [:logo])
    |> validate_required(required_attrs)
    |> maybe_put_name()
    |> validate_format(:name, @name_regex)
    |> unique_constraint(:name)
    |> Helpers.maybe_put_tags_assoc(attrs)
  end

  @doc """
  Builds a changeset for updating a publication.

  ## Examples

      iex> update_changeset(%Publication, attrs)
      %Ecto.Changeset{}

  """
  @spec update_changeset(t(), map()) :: Ecto.Changeset.t()
  def update_changeset(%Publication{} = publication, attrs) do
    update_permitted_attrs = ~w(
      name
      display_name
      description
      website
    )a

    publication
    |> cast(attrs, update_permitted_attrs)
    |> cast_attachments(attrs, [:logo])
    |> maybe_put_name()
    |> validate_format(:name, @name_regex)
    |> unique_constraint(:name)
    |> Helpers.maybe_put_tags_assoc(attrs)
  end

  # If the name hasn't been specified,
  # we use the slugified display_name as the name.
  defp maybe_put_name(changeset) do
    case fetch_field(changeset, :name) do
      {_, _name} ->
        changeset

      :error ->
        name =
          changeset
          |> get_field(:display_name)
          |> Slugger.slugify_downcase()

        put_change(changeset, :name, name)
    end
  end

  @doc """
  Preloads the tags of a publication.
  """
  @spec preload_tags(t()) :: t()
  def preload_tags(%Publication{} = publication), do: Repo.preload(publication, :tags)
end
