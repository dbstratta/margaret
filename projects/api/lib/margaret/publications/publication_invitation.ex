defmodule Margaret.Publications.PublicationInvitation do
  @moduledoc """
  The Publication Invitation schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Publications.Publication
  }

  @type t :: %PublicationInvitation{}

  defenum(PublicationInvitationStatus, :publication_invitation_status, [
    :accepted,
    :pending,
    :rejected
  ])

  defenum(PublicationInvitationRole, :publication_invitation_role, [:writer, :editor, :admin])

  schema "publication_invitations" do
    belongs_to(:invitee, User)
    belongs_to(:inviter, User)
    belongs_to(:publication, Publication)

    # The role that the invitee will have if they accept.
    field(:role, PublicationInvitationRole)
    field(:status, PublicationInvitationStatus)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a publication invitation.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      invitee_id
      inviter_id
      publication_id
      role
      status
    )a

    required_attrs = ~w(
      invitee_id
      inviter_id
      publication_id
      role
    )a

    %PublicationInvitation{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:invitee)
    |> assoc_constraint(:inviter)
    |> assoc_constraint(:publication)
  end

  @doc """
  Builds a changeset for updating a publication invitation.
  """
  def update_changeset(%PublicationInvitation{} = publication_invitation, attrs) do
    permitted_attrs = ~w(
      status
    )a

    publication_invitation
    |> cast(attrs, permitted_attrs)
  end

  @doc """
  Preloads the invitee of a publication invitation.
  """
  @spec preload_invitee(t) :: t
  def preload_invitee(%PublicationInvitation{} = publication_invitation),
    do: Repo.preload(publication_invitation, :invitee)

  @doc """
  Preloads the inviter of a publication invitation.
  """
  @spec preload_inviter(t) :: t
  def preload_inviter(%PublicationInvitation{} = publication_invitation),
    do: Repo.preload(publication_invitation, :inviter)

  @doc """
  Preloads the publication of a publication invitation.
  """
  @spec preload_publication(t) :: t
  def preload_publication(%PublicationInvitation{} = publication_invitation),
    do: Repo.preload(publication_invitation, :publication)
end
