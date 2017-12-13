defmodule MargaretWeb.Schema.DeletableTypes do
  @moduledoc """
  The Deletable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  interface :deletable do
    field :viewer_can_delete, non_null(:boolean)

    resolve_type &Resolvers.Nodes.resolve_type/2
  end
end
