defmodule Margaret.Publications.PublicationMembership do
  @moduledoc """
  The Publication Membership schema and changesets.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Publications.Publication
  }

  @type t :: %PublicationMembership{}

  defenum(PublicationMembershipRole, :publication_membership_role, [
    :owner,
    :admin,
    :writer,
    :editor
  ])

  schema "publication_memberships" do
    field(:role, PublicationMembershipRole)

    belongs_to(:member, User)
    belongs_to(:publication, Publication)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a publication membership.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      role
      member_id
      publication_id
    )a

    required_attrs = ~w(
     role
     member_id
     publication_id
    )a

    %PublicationMembership{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:member)
    |> assoc_constraint(:publication)
    |> unique_constraint(:member_id)
  end

  @doc """
  Builds a changeset for updating a publication membership.
  """
  def update_changeset(%PublicationMembership{} = publication_membership, attrs) do
    permitted_attrs = ~w(
      role
    )a

    publication_membership
    |> cast(attrs, permitted_attrs)
  end

  @doc """
  Filters the publication memberships by publication.
  """
  @spec by_publication(Ecto.Query.t(), Publication.t()) :: Ecto.Query.t()
  def by_publication(query \\ PublicationMembership, %Publication{id: publication_id}),
    do: where(query, [..., pm], pm.publication_id == ^publication_id)

  @doc """
  Filters the publication memberships by member.
  """
  @spec by_member(Ecto.Query.t(), User.t()) :: Ecto.Query.t()
  def by_member(query \\ PublicationMembership, %User{id: member_id}),
    do: where(query, [..., pm], pm.member_id == ^member_id)

  @doc """
  Filters the publication memberships by owner.
  """
  @spec owner(Ecto.Query.t()) :: Ecto.Query.t()
  def owner(query \\ PublicationMembership), do: where(query, [..., pm], pm.role == ^:role)

  @doc """
  Preloads the member of a publication_membership.
  """
  @spec preload_member(t) :: t
  def preload_member(%PublicationMembership{} = publication_membership),
    do: Repo.preload(publication_membership, :member)

  @doc """
  Preloads the publication of a publication_membership.
  """
  @spec preload_publication(t) :: t
  def preload_publication(%PublicationMembership{} = publication_membership),
    do: Repo.preload(publication_membership, :publication)
end
