defmodule MargaretWeb.Schema.CollectionTypes do
  @moduledoc """
  The Collection GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.{Resolvers, Middleware}

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

    @desc "The cover URL of the collection."
    field(:cover, :string)

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

    field :viewer_can_bookmark, non_null(:boolean) do
      middleware(Middleware.RequireAuthenticated, resolve: false)
      resolve(&Resolvers.Collections.resolve_viewer_can_bookmark/3)
    end

    field :viewer_has_bookmarked, non_null(:boolean) do
      middleware(Middleware.RequireAuthenticated, resolve: false)
      resolve(&Resolvers.Collections.resolve_viewer_has_bookmarked/3)
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

  object :collection_mutations do
    @desc "Creates a collection."
    payload field(:create_collection) do
      input do
        field(:title, non_null(:string))
        field(:subtitle, non_null(:string))
        field(:description, :string)
        field(:cover, :upload)
        field(:slug, :string)

        field(:publication_id, :id)
        field(:tags, list_of(:string))
      end

      output do
        field(:collection, non_null(:collection))
      end

      middleware(Absinthe.Relay.Node.ParseIDs, publication_id: :publication)
      resolve(&Resolvers.Collections.resolve_create_collection/2)
    end

    @desc "Updates a collection."
    payload field(:update_collection) do
      input do
        field(:collection_id, non_null(:id))
        field(:subtitle, :string)
        field(:description, :string)
        field(:cover, :upload)
        field(:slug, :string)

        field(:publication_id, :id)
        field(:tags, list_of(:string))
      end

      output do
        field(:collection, non_null(:collection))
      end

      middleware(Absinthe.Relay.Node.ParseIDs, collection_id: :collection)
      resolve(&Resolvers.Collections.resolve_update_collection/2)
    end
  end
end
