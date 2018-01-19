defmodule MargaretWeb.Schema.UpdatableTypes do
  @moduledoc """
  The Updatable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  interface :updatable do
    field(:viewer_can_update, non_null(:boolean))

    resolve_type(&Resolvers.Nodes.resolve_type/2)
  end
end
