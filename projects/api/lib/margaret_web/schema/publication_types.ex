defmodule MargaretWeb.Schema.PublicationTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  node object :publication do
    field :name, non_null(:string)
  end

  object :publication_queries do
    @desc "Lookup a publication by its name."
    field :publication, :publication do
      arg :name, :string
      arg :id, :id

      resolve &Resolvers.Publications.resolve_publication_by_name/2
    end
  end
end
