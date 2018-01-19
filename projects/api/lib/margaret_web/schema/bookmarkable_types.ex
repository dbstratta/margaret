defmodule MargaretWeb.Schema.BookmarkableTypes do
  @moduledoc """
  The Bookmarkable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  @desc """
  Things that can be bookmarkable.
  """
  interface :bookmarkable do
    field(:id, non_null(:id))

    @desc """
    Indicates whether the viewer can bookmark this bookmarkable.
    """
    field(:viewer_can_bookmark, non_null(:boolean))

    @desc """
    Returns a boolean indicating whether the viewing user has bookmarked this bookmarkable.
    """
    field(:viewer_has_bookmarked, non_null(:boolean))

    resolve_type(&Resolvers.Nodes.resolve_type/2)
  end

  @desc """
  The connection type for Bookmarked.
  """
  connection :bookmarked, node_type: :bookmarkable do
    @desc "The total count of stories bookmarked."
    field(:total_count, non_null(:integer))

    @desc "An edge in a connection."
    edge do
      field(:bookmarked_at, non_null(:naive_datetime))
    end
  end

  @desc """
  The connection type for Bookmarkable.
  """
  connection node_type: :bookmarkable do
    @desc "The total count of bookmarkables."
    field(:total_count, non_null(:integer))

    @desc "An edge in a connection."
    edge do
    end
  end

  object :bookmarkable_mutations do
    @desc "Bookmarks a bookmarkable."
    payload field(:bookmark) do
      input do
        @desc "The id of the bookmarkable."
        field(:bookmarkable_id, non_null(:id))
      end

      output do
        field(:bookmarkable, non_null(:bookmarkable))
      end

      middleware(Absinthe.Relay.Node.ParseIDs, bookmarkable_id: [:story, :comment])
      resolve(&Resolvers.Bookmarkable.resolve_bookmark/2)
    end

    @desc "Unbookmarks a bookmarkable."
    payload field(:unbookmark) do
      input do
        @desc "The id of the bookmarkable."
        field(:bookmarkable_id, non_null(:id))
      end

      output do
        field(:bookmarkable, non_null(:bookmarkable))
      end

      middleware(Absinthe.Relay.Node.ParseIDs, bookmarkable_id: [:story, :comment])
      resolve(&Resolvers.Bookmarkable.resolve_unbookmark/2)
    end
  end
end
