defmodule MargaretWeb.Schema.FollowableTypes do
  @moduledoc """
  The Followable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  @followable_implementations [
    :user,
    :publication,
  ]

  interface :followable do
    field :id, non_null(:id)

    @desc "The followers of the followable."
    field :followers, :follower_connection

    @desc "Returns a boolean indicating whether the viewing user can follow this followable."
    field :viewer_can_follow, non_null(:boolean)

    @desc "Returns a boolean indicating whether the viewing user has followed this followable."
    field :viewer_has_followed, non_null(:boolean)

    resolve_type &Resolvers.Nodes.resolve_type/2
  end

  object :followable_mutations do
    @desc "Follows a followable."
    payload field :follow do
      input do
        field :followable_id, non_null(:id)
      end

      output do
        field :followable, non_null(:followable)
      end

      middleware Absinthe.Relay.Node.ParseIDs, followable_id: @followable_implementations
      resolve &Resolvers.Followable.resolve_follow/2
    end

    @desc "Follows a followable."
    payload field :unfollow do
      input do
        field :followable_id, non_null(:id)
      end

      output do
        field :followable, non_null(:followable)
      end

      middleware Absinthe.Relay.Node.ParseIDs, followable_id: @followable_implementations
      resolve &Resolvers.Followable.resolve_unfollow/2
    end
  end
end
