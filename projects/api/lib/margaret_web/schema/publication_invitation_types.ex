defmodule MargaretWeb.Schema.PublicationInvitationTypes do
  @moduledoc """
  The Publication Invitation GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  import MargaretWeb.Resolvers.PublicationInvitations

  connection node_type: :publication_invitation

  @desc """
  A publication membership invitation represents an
  invitation from a user from a publication to another user
  not from the publication.
  """
  node object :publication_invitation do
    field :publication, non_null(:publication) do
      resolve &resolve_publication/3
    end

    field :invitee, non_null(:user) do
      resolve &resolve_invitee/3
    end

    field :inviter, non_null(:user) do
      resolve &resolve_inviter/3
    end

    field :status, non_null(:string)
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
      end

      output do
        field :invitation, non_null(:publication_invitation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, invitee_id: :user
      middleware Absinthe.Relay.Node.ParseIDs, publication_id: :publication
      resolve &resolve_send_publication_invitation/2
    end

    @desc """
    """
    payload field :accept_publication_invitation do
      input do
        field :invitation_id, non_null(:id)
      end

      output do
        field :invitation, non_null(:publication_invitation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, invitation_id: :publication_invitation
      resolve &resolve_accept_publication_invitation/2
    end

    @desc """
    """
    payload field :reject_publication_invitation do
      input do
        field :invitation_id, non_null(:id)
      end

      output do
        field :invitation, non_null(:publication_invitation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, invitation_id: :publication_invitation
      resolve &resolve_reject_publication_invitation/2
    end
  end
end
