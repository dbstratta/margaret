defmodule MargaretWeb.Schema.PublicationTypes do
  @moduledoc """
  The Publication GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.{Resolvers, Middleware}

  @desc "The role of a user on a publication."
  enum :publication_member_role do
    value :owner
    value :admin
    value :editor
    value :writer
  end

  @desc """
  The connection type for Publication.
  """
  connection node_type: :publication do
    @desc "The total count of publications."
    field :total_count, non_null(:integer)

    @desc "An edge in a connection."
    edge do end
  end

  @desc """
  The connection type for PublicationMember.
  """
  connection :publication_member, node_type: :user do
    @desc "The total count of members."
    field :total_count, non_null(:integer)

    @desc "An edge in a connection."
    edge do
      @desc "The datetime since the user is a member of the publication."
      field :member_since, non_null(:naive_datetime)

      @desc "The role of the user in the publication."
      field :role, non_null(:publication_member_role)
    end
  end

  @desc """
  The connection type for UserPublication.
  """
  connection :user_publication, node_type: :publication do
    @desc "The total count of publications."
    field :total_count, non_null(:integer)

    @desc "An edge in a connection."
    edge do
      @desc "The datetime since the user is a member of the publication."
      field :member_since, non_null(:naive_datetime)

      @desc "The role of the user in the publication."
      field :role, non_null(:publication_member_role)
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
    connection field :members, node_type: :user, connection: :publication_member do
      resolve &Resolvers.Publications.resolve_members/3
    end

    @desc "The stories published under the publication."
    connection field :stories, node_type: :story do
      resolve &Resolvers.Publications.resolve_stories/3
    end

    @desc """
    The follower connection of the publication.
    """
    connection field :followers, node_type: :user, connection: :follower do
      resolve &Resolvers.Publications.resolve_followers/3
    end

    field :tags, non_null(list_of(:tag)) do
      resolve &Resolvers.Publications.resolve_tags/3
    end

    @desc "The membership invitations of the publication."
    connection field :membership_invitations, node_type: :publication_invitation do
      middleware Middleware.RequireAuthenticated, resolve: nil
      resolve &Resolvers.Publications.resolve_membership_invitations/3
    end

    field :viewer_can_follow, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Publications.resolve_viewer_can_follow/3
    end

    field :viewer_has_followed, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Publications.resolve_viewer_has_followed/3
    end

    @desc "Viewer is a member of the publication."
    field :viewer_is_a_member, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Publications.resolve_viewer_is_a_member/3
    end

    @desc "Viewer can administer the publication."
    field :viewer_can_administer, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
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
        field :name, :string
        field :display_name, non_null(:string)
        field :tags, list_of(:string)
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
    Leaves a publication.
    """
    payload field :leave_publication do
      input do
        field :publication_id, non_null(:id)
      end

      output do
        field :publication, non_null(:publication)
      end

      middleware Absinthe.Relay.Node.ParseIDs, publication_id: :publication
      resolve &Resolvers.Publications.resolve_leave_publication/2
    end

    @desc """
    Updates a publication.
    """
    payload field :update_publication do
      input do
        field :publication_id, non_null(:id)
        field :name, :string
        field :display_name, :string
        field :tags, list_of(:string)
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
