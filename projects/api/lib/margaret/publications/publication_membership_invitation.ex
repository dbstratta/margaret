defmodule Margaret.Publications.PublicationMembershipInvitation do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__, as: PublicationMembershipInvitation
  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.Publication

  @typedoc "The Publication type"
  @type t :: %PublicationMembershipInvitation{}

  defenum PublicationMembershipInvitationStatus,
    :publication_membership_invitation_status,
    [:accepted, :pending, :rejected]

  schema "publication_membership_invitations" do
    belongs_to :invitee, User
    belongs_to :inviter, User
    belongs_to :publication, Publication
    field :status, PublicationMembershipInvitationStatus

    timestamps()
  end

  @doc false
  def changeset(%PublicationMembershipInvitation{} = publication_membership_invitation, attrs) do
    publication_membership_invitation
    |> cast(attrs, [:role, :member_id, :publication_id])
    |> validate_required([:role, :member_id, :publication_id])
    |> foreign_key_constraint(:member_id)
    |> foreign_key_constraint(:publication_id)
    |> unique_constraint(:member_id)
  end
end
