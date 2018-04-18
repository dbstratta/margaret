defmodule MargaretWeb.Resolvers.Collections do
  @moduledoc """
  The Collection GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  import MargaretWeb.Helpers, only: [ok: 1]
  alias MargaretWeb.Helpers

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Bookmarks,
    Publications,
    Collections
  }

  alias Accounts.User
  alias Stories.Story

  @doc """
  Resolves the author of the collection.
  """
  def resolve_author(collection, _, _) do
    collection
    |> Collections.author()
    |> ok()
  end

  def resolve_stories(_collection, _args, _) do
    Helpers.GraphQLErrors.not_implemented()
  end

  @doc """
  Resolves the publication of the collection.
  """
  def resolve_publication(collection, _, _) do
    publication = Collections.publication(collection)

    {:ok, publication}
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
  def resolve_viewer_can_bookmark(_collection, _args, _resolution), do: {:ok, true}

  @doc """
  Resolves whether the viewer has bookmarked the collection or not.
  """
  def resolve_viewer_has_bookmarked(collection, _, %{context: %{viewer: viewer}}) do
    has_bookmarked = Bookmarks.has_bookmarked?(user: viewer, collection: collection)

    {:ok, has_bookmarked}
  end

  @doc """
  """
  def resolve_collection(%{slug: slug}, _) do
    collection = Collections.get_collection_by_slug(slug)

    {:ok, collection}
  end

  def resolve_create_collection(_args, %{context: %{viewer: _viewer}}) do
  end

  def resolve_update_collection(_args, %{context: %{viewer: _viewer}}) do
  end
end
