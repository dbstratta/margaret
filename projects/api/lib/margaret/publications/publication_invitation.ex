defmodule Margaret.Publications.PublicationInvitation do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__, as: PublicationInvitation
  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.Publication

  @typedoc "The Publication type"
  @type t :: %PublicationInvitation{}

  defenum PublicationInvitationStatus,
    :publication_invitation_status,
    [:accepted, :pending, :rejected]

  schema "publication_invitations" do
    belongs_to :invitee, User
    belongs_to :inviter, User
    belongs_to :publication, Publication
    field :status, PublicationInvitationStatus

    timestamps()
  end

  @doc false
  def changeset(%PublicationInvitation{} = publication_invitation, attrs) do
    publication_invitation
    |> cast(attrs, [:invitee_id, :inviter_id, :publication_id])
    |> validate_required([:invitee_id, :inviter_id, :publication_id])
    |> foreign_key_constraint(:invitee_id)
    |> foreign_key_constraint(:inviter_id)
    |> foreign_key_constraint(:publication_id)
  end
end
