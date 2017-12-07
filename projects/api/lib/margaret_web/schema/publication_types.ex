defmodule MargaretWeb.Schema.PublicationTypes do
  @moduledoc """
  The Publication GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  node object :publication do
    field :name, non_null(:string)
  end

  object :publication_queries do
    @desc "Lookup a publication by its name."
    field :publication, :publication do
      arg :name, non_null(:string)

      resolve &Resolvers.Publications.resolve_publication/2
    end
  end
end
