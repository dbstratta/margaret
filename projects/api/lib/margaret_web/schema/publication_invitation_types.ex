defmodule MargaretWeb.Schema.PublicationInvitationTypes do
  @moduledoc """
  The Publication Invitation GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  @desc "The role of a invitation."
  enum :publication_invitation_role do
    value :admin
    value :writer
    value :editor
  end

  @desc "The status of a invitation."
  enum :publication_invitation_status do
    value :accepted
    value :pending
    value :rejected
  end

  @desc """
  The connection type for PublicationInvitation.
  """
  connection node_type: :publication_invitation do
    @desc "The total count of publication invitations."
    field :total_count, non_null(:integer)

    @desc "An edge in a connection."
    edge do end
  end

  @desc """
  A publication membership invitation represents an
  invitation from a user from a publication to another user
  not from the publication.
  """
  node object :publication_invitation do
    @desc """
    The publication of the invitation.
    """
    field :publication, non_null(:publication) do
      resolve &Resolvers.PublicationInvitations.resolve_publication/3
    end

    @desc """
    The invitee of the invitation.
    """
    field :invitee, non_null(:user) do
      resolve &Resolvers.PublicationInvitations.resolve_invitee/3
    end

    @desc """
    The inviter of the inviation.
    """
    field :inviter, non_null(:user) do
      resolve &Resolvers.PublicationInvitations.resolve_inviter/3
    end

    @desc """
    The role of the user on the publication should they accept the invitation.
    """
    field :role, non_null(:publication_invitation_role)

    @desc """
    The status of the invitation.
    """
    field :status, non_null(:publication_invitation_status)

    @desc """
    Identifies the date and time when the inviation was sent.
    """
    field :inserted_at, non_null(:naive_datetime)
  end

  object :publication_invitation_mutations do
    @desc """
    Sends an invitation to join the publication.
    """
    payload field :send_publication_invitation do
      input do
        @desc "The id of the invitee."
        field :invitee_id, non_null(:id)
        @desc "The id of the publication."
        field :publication_id, non_null(:id)

        @desc "The role of the invitee on the publication."
        field :role, non_null(:publication_invitation_role)
      end

      output do
        field :invitation, non_null(:publication_invitation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, invitee_id: :user
      middleware Absinthe.Relay.Node.ParseIDs, publication_id: :publication
      resolve &Resolvers.PublicationInvitations.resolve_send_publication_invitation/2
    end

    @desc """
    Accepts the invitation.
    """
    payload field :accept_publication_invitation do
      input do
        @desc "The id of the invitation."
        field :invitation_id, non_null(:id)
      end

      output do
        field :invitation, non_null(:publication_invitation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, invitation_id: :publication_invitation
      resolve &Resolvers.PublicationInvitations.resolve_accept_publication_invitation/2
    end

    @desc """
    Rejects the invitation.
    """
    payload field :reject_publication_invitation do
      input do
        @desc "The id of the invitation."
        field :invitation_id, non_null(:id)
      end

      output do
        field :invitation, non_null(:publication_invitation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, invitation_id: :publication_invitation
      resolve &Resolvers.PublicationInvitations.resolve_reject_publication_invitation/2
    end
  end
end
