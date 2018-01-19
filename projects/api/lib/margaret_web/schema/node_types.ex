defmodule MargaretWeb.Schema.NodeTypes do
  @moduledoc """
  The Node GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  node interface do
    resolve_type(&Resolvers.Nodes.resolve_type/2)
  end

  object :node_queries do
    @desc "Lookup a node by its global id."
    node field do
      resolve(&Resolvers.Nodes.resolve_node/2)
    end
  end
end
