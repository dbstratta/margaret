defmodule MargaretWeb.Schema.SearchTypes do
  @moduledoc """
  The Search GraphQL types definitions.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  @desc """
  """
  union :search_result do
    types([:user, :story])

    resolve_type(&Resolvers.Nodes.resolve_type/2)
  end

  connection node_type: :search_result do
    @desc "The total count of users."
    field(:total_count, non_null(:integer))

    # We need to call the `edge` macro in custom connection types.
    @desc "An edge in a connection."
    edge do
    end
  end

  object :search_queries do
    @desc """
    """
    connection field(:search, node_type: :search_result) do
      resolve(&Resolvers.Search.resolve_search/3)
    end
  end
end
