defmodule MargaretWeb.Schema.NodeTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  node interface do
    resolve_type fn
      _, _ ->
        nil
    end
  end

  object :node_queries do
    @desc "Lookup a node by its global id."
    node field do
      resolve &Resolvers.Nodes.resolve_node/2
    end
  end
end
