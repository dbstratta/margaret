defmodule MargaretWeb.Schema.PublicationTypes do
  @moduledoc """
  The Publication GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  connection node_type: :publication

  connection node_type: :publication_member do
    edge do
      field :node, non_null(:user)

      field :role, non_null(:string) do
        resolve &Resolvers.Publications.resolve_member_role/3
      end
    end
  end

  @desc """
  A Publication is a organization that has members (writers, editors, among others).
  Its writers can publish stories under the publication name.
  """
  node object :publication do
    @desc "The name of the publication."
    field :name, non_null(:string)

    @desc "The display name of the publication."
    field :display_name, non_null(:string)

    field :owner, non_null(:user) do
      resolve &Resolvers.Publications.resolve_owner/3
    end

    @desc "The members of the publication."
    connection field :members, node_type: :publication_member do
      resolve &Resolvers.Publications.resolve_members/3
    end

    @desc "The stories published under the publication."
    connection field :stories, node_type: :story do
      resolve &Resolvers.Publications.resolve_stories/3
    end

    @desc """
    The follower connection of the publication.
    """
    connection field :followers, node_type: :user do
      resolve &Resolvers.Accounts.resolve_followers/3
    end

    @desc "The membership invitations of the publication."
    connection field :membership_invitations, node_type: :publication_invitation do
      resolve &Resolvers.Publications.resolve_membership_invitations/3
    end

    field :viewer_can_follow, non_null(:boolean) do
      resolve &Resolvers.Publications.resolve_viewer_can_follow/3
    end

    field :viewer_has_followed, non_null(:boolean) do
      resolve &Resolvers.Publications.resolve_viewer_has_followed/3
    end

    @desc "Viewer is a member of the publication."
    field :viewer_is_a_member, non_null(:boolean) do
      resolve &Resolvers.Publications.resolve_viewer_is_a_member/3
    end

    @desc "Viewer can administer the publication."
    field :viewer_can_administer, non_null(:boolean) do
      resolve &Resolvers.Publications.resolve_viewer_can_administer/3
    end

    interfaces [:followable]
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
        field :display_name, non_null(:string)
      end

      output do
        field :publication, non_null(:publication)
      end

      resolve &Resolvers.Publications.resolve_create_publication/2
    end

    @desc """
    Kicks a member out of a publication.
    """
    payload field :kick_publication_member do
      input do
        field :member_id, non_null(:id)
        field :publication_id, non_null(:id)
      end

      output do
        field :publication, non_null(:publication)
      end

      middleware Absinthe.Relay.Node.ParseIDs, member_id: :user
      middleware Absinthe.Relay.Node.ParseIDs, publication_id: :publication
      resolve &Resolvers.Publications.resolve_kick_member/2
    end

    @desc """
    Updates a publication.
    """
    payload field :update_publication do
      input do
        field :publication_id, non_null(:id)
      end

      output do
        field :publication, non_null(:publication)
      end

      middleware Absinthe.Relay.Node.ParseIDs, publication_id: :publication
      resolve &Resolvers.Publications.resolve_update_publication/2
    end

    @desc """
    Deletes a publication.
    """
    payload field :delete_publication do
      input do
        field :publication_id, non_null(:id)
      end

      output do
        field :publication, non_null(:publication)
      end

      middleware Absinthe.Relay.Node.ParseIDs, publication_id: :publication
      resolve &Resolvers.Publications.resolve_delete_publication/2
    end
  end
end
