defmodule MargaretWeb.Schema.StarrableTypes do
  @moduledoc """
  The Starrable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  interface :starrable do
    field :id, non_null(:id)

    @desc "The stargazers of the starrable."
    field :stargazers, :user_connection

    @desc "The star count of the starrable."
    field :star_count, non_null(:integer)

    @desc "Check if the current viewer can delete this object."
    field :viewer_can_star, non_null(:boolean)

    @desc "Returns a boolean indicating whether the viewing user has starred this starrable."
    field :viewer_has_starred, non_null(:boolean)

    resolve_type &Resolvers.Nodes.resolve_type/2
  end

  object :starrable_mutations do
    @desc "Stars a starrable."
    payload field :star do
      input do
        field :starrable_id, non_null(:id)
      end

      output do
        field :starrable, non_null(:starrable)
      end

      middleware Absinthe.Relay.Node.ParseIDs, starrable_id: [:story, :comment]
      resolve &Resolvers.Starrable.resolve_star/2
    end

    @desc "Unstars a starrable."
    payload field :unstar do
      input do
        field :starrable_id, non_null(:id)
      end

      output do
        field :starrable, non_null(:starrable)
      end

      middleware Absinthe.Relay.Node.ParseIDs, starrable_id: [:story, :comment]
      resolve &Resolvers.Starrable.resolve_unstar/2
    end
  end

  object :starrable_subscriptions do
    field :starrable_starred, :starrable do
      arg :starrable_id, non_null(:id)
    end
  end
end
