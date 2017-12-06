defmodule MargaretWeb.Schema do
  @moduledoc """
  The GraphQL schema.
  """

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types Absinthe.Type.Custom

  import_types MargaretWeb.Schema.NodeTypes
  import_types MargaretWeb.Schema.AccountTypes
  import_types MargaretWeb.Schema.StoryTypes
  import_types MargaretWeb.Schema.PublicationTypes
  import_types MargaretWeb.Schema.StarrableTypes

  alias MargaretWeb.Resolvers

  @desc "The root query type."
  query do
    import_fields :node_queries
    import_fields :account_queries
    import_fields :story_queries
    import_fields :publication_queries
  end

  @desc "The root mutation type."
  mutation do
    import_fields :account_mutations
    import_fields :story_mutations
    import_fields :starrable_mutations
  end
end
