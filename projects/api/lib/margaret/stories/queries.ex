defmodule Margaret.Stories.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{Accounts, Stories, Collections}
  alias Accounts.User
  alias Stories.Story
  alias Collections.Collection

  @doc """
  """
  @spec stories(map()) :: Ecto.Query.t()
  def stories(args \\ %{}) do
    query = Story

    query
    |> maybe_filter_by_author(args)
    |> maybe_filter_by_publication(args)
    |> maybe_filter_by_collection(args)
    |> maybe_filter_published_only(args)
  end

  @spec maybe_filter_by_author(Ecto.Queryable.t(), map()) :: Ecto.Queryable.t()
  defp maybe_filter_by_author(query, args) do
    case Map.get(args, :author) do
      %User{id: author_id} ->
        from(s in query, where: s.author_id == ^author_id)

      nil ->
        query
    end
  end

  @spec maybe_filter_by_publication(Ecto.Queryable.t(), map()) :: Ecto.Queryable.t()
  defp maybe_filter_by_publication(query, args) do
    case Map.get(args, :publication) do
      %User{id: publication_id} ->
        from(s in query, where: s.publication_id == ^publication_id)

      nil ->
        query
    end
  end

  @spec maybe_filter_by_collection(Ecto.Queryable.t(), map()) :: Ecto.Queryable.t()
  def maybe_filter_by_collection(query, args) do
    case Map.get(args, :collection) do
      %Collection{id: collection_id} ->
        from(
          s in query,
          join: cs in assoc(s, :collection_story),
          where: cs.collection_id == ^collection_id
        )

      nil ->
        query
    end
  end

  @spec maybe_filter_published_only(Ecto.Queryable.t(), map()) :: Ecto.Queryable.t()
  defp maybe_filter_published_only(query, args) do
    if Map.get(args, :published_only, true) do
      from(s in query, where: s.published_at <= ^NaiveDateTime.utc_now())
    else
      query
    end
  end
end
