defmodule Margaret.Publications.PublicationInvitation do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__
  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.Publication

  @type t :: %PublicationInvitation{}

  @permitted_attrs [
    :invitee_id,
    :inviter_id,
    :publication_id,
    :role,
    :status
  ]

  @required_attrs [
    :invitee_id,
    :inviter_id,
    :publication_id,
    :role
  ]

  @update_permitted_attrs [
    :status
  ]

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

    field(:role, PublicationInvitationRole)
    field(:status, PublicationInvitationStatus)

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %PublicationInvitation{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:invitee_id)
    |> foreign_key_constraint(:inviter_id)
    |> foreign_key_constraint(:publication_id)
  end

  @doc false
  def update_changeset(%PublicationInvitation{} = publication_invitation, attrs) do
    publication_invitation
    |> cast(attrs, @update_permitted_attrs)
  end
end
