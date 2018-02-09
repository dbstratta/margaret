defmodule MargaretWeb.Resolvers.Collections do
  @moduledoc """
  The Collection GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

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
    author = Collections.get_author(collection)

    {:ok, author}
  end

  def resolve_stories(_collection, _args, _) do
    Helpers.GraphQLErrors.not_implemented()
  end

  @doc """
  Resolves the publication of the collection.
  """
  def resolve_publication(collection, _, _) do
    publication = Collections.get_publication(collection)

    {:ok, publication}
  end

  @doc """
  Resolves the tags of the collection.
  """
  def resolve_tags(collection, _, _) do
    tags = Collections.get_tags(collection)

    {:ok, tags}
  end

  def resolve_collection(%{slug: slug}, _) do
    collection = Collections.get_collection_by_slug(slug)

    {:ok, collection}
  end
end
