defmodule MargaretWeb.Schema.PublicationTypes do
  @moduledoc """
  The Publication GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  connection node_type: :publication
  connection node_type: :publication_membership_invitation

  @desc """
  A Publication is a organization that has members (writers, editors, among others).
  Its writers can publish stories under the publication name.
  """
  node object :publication do
    field :name, non_null(:string)

    connection field :members, node_type: :user do
      resolve &Resolvers.Publications.resolve_members/3
    end

    connection field :membership_invitations, node_type: :publication_membership_invitation do
      resolve &Resolvers.Publications.resolve_membership_invitations/3
    end
  end

  @desc """
  A publication membership invitation represents an
  invitation from a user from a publication to another user
  not from the publication.
  """
  node object :publication_membership_invitation do
    field :publication, non_null(:publication)
    field :invitee, non_null(:user)
    field :inviter, non_null(:user)

    field :status, non_null(:string)
  end

  object :publication_queries do
    @desc """
    Lookup a publication by its name.
    """
    field :publication, :publication do
      arg :name, non_null(:string)

      resolve &Resolvers.Publications.resolve_publication/2
    end
  end

  object :publication_mutations do
    @desc """
    Creates a publication.
    """
    payload field :create_publication do
      input do
        field :name, non_null(:string)
        field :display_name, non_null(:id)
      end

      output do
        field :publication, non_null(:publication)
      end

      resolve &Resolvers.Publications.resolve_create_publication/2
    end

    @desc """
    Sends an invitation to join the publication.
    """
    payload field :send_invitation_publication_membership do
      input do
        field :username, non_null(:string)
        field :publication_id, non_null(:id)
      end

      output do
        field :invitation, non_null(:publication_membership_invitation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, publication_id: :publication
      resolve &Resolvers.Publications.resolve_send_publication_membership_invitation/2
    end

    @desc """
    """
    payload field :accept_publication_membership_invitation do
      input do
        field :invitation_id, non_null(:id)
      end

      output do
        field :invitation, non_null(:publication_membership_invitation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, invitation_id: :publication_membership_invitation
      resolve &Resolvers.Publications.resolve_accept_publication_membership_invitation/2
    end

    @desc """
    """
    payload field :reject_publication_membership_invitation do
      input do
        field :invitation_id, non_null(:id)
      end

      output do
        field :invitation, non_null(:publication_membership_invitation)
      end

      middleware Absinthe.Relay.Node.ParseIDs, invitation_id: :publication_membership_invitation
      resolve &Resolvers.Publications.resolve_reject_publication_membership_invitation/2
    end
  end
end
