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
end
