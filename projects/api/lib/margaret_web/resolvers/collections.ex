defmodule MargaretWeb.Resolvers.Collections do
  @moduledoc """
  The Collection GraphQL resolvers.
  """

  import MargaretWeb.Helpers, only: [ok: 1]
  alias MargaretWeb.Helpers

  alias Margaret.{
    Accounts,
    Stories,
    Bookmarks,
    Publications,
    Collections
  }

  @doc """
  Resolves the author of the collection.
  """
  def resolve_author(collection, _, _) do
    collection
    |> Collections.author()
    |> ok()
  end

  def resolve_stories(collection, args, _) do
    args
    |> Map.put(:collection, collection)
    |> Stories.stories()
  end

  @doc """
  Resolves the publication of the collection.
  """
  def resolve_publication(collection, _, _) do
    collection
    |> Collections.publication()
    |> ok()
  end

  @doc """
  Resolves the tags of the collection.
  """
  def resolve_tags(collection, _, _) do
    collection
    |> Collections.tags()
    |> ok()
  end

  @doc """
  Resolves whether the viewer can bookmark the collection or not.
  """
  def resolve_viewer_can_bookmark(_collection, _args, _resolution), do: ok(true)

  @doc """
  Resolves whether the viewer has bookmarked the collection or not.
  """
  def resolve_viewer_has_bookmarked(collection, _, %{context: %{viewer: viewer}}) do
    [user: viewer, collection: collection]
    |> Bookmarks.has_bookmarked?()
    |> ok()
  end

  @doc """
  """
  def resolve_collection(%{slug: slug}, _) do
    slug
    |> Collections.get_collection_by_slug()
    |> ok()
  end

  def resolve_create_collection(_args, %{context: %{viewer: _viewer}}) do
    Helpers.GraphQLErrors.not_implemented()
  end

  def resolve_update_collection(_args, %{context: %{viewer: _viewer}}) do
    Helpers.GraphQLErrors.not_implemented()
  end
end
