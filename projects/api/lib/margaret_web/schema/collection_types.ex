defmodule MargaretWeb.Schema.CollectionTypes do
  @moduledoc """
  The Collection GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  @desc """
  The connection type for Collection.
  """
  connection node_type: :collection do
    @desc "The total count of collection."
    field(:total_count, non_null(:integer))

    @desc "An edge in a connection."
    edge do
    end
  end

  @desc """
  A Collection is a group of stories.
  """
  node object(:collection) do
    @desc "The title of the collection."
    field(:title, non_null(:string))

    @desc "The subtitle of the collection."
    field(:subtitle, non_null(:string))

    @desc "The description of the collection."
    field(:description, :string)

    @desc "The author of the collection."
    field :author, non_null(:user) do
      resolve(&Resolvers.Collections.resolve_author/3)
    end

    @desc "The slug of the collection."
    field(:slug, non_null(:string))

    @desc "The stories in the collection."
    connection field(:stories, node_type: :story) do
      resolve(&Resolvers.Collections.resolve_stories/3)
    end

    @desc "The publication of the collection, if it has one."
    field :publication, :publication do
      resolve(&Resolvers.Collections.resolve_publication/3)
    end

    @desc "The tags of the collection."
    field :tags, list_of(:tag) do
      resolve(&Resolvers.Collections.resolve_tags/3)
    end

    @desc "Identifies the date and time when the collection was created."
    field(:inserted_at, non_null(:naive_datetime))

    @desc "Identifies the date and time when the collection was last updated."
    field(:updated_at, non_null(:naive_datetime))

    interfaces([:bookmarkable])
  end

  object :collection_queries do
    @desc "Lookup a collection by its slug."
    field :collection, :collection do
      arg(:slug, non_null(:string))

      resolve(&Resolvers.Collections.resolve_collection/2)
    end
  end

  object :story_mutations do
  end
end
