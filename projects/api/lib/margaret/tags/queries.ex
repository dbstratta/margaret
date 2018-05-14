defmodule Margaret.Tags.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{
    Tags
  }

  alias Tags.Tag

  def tags(args \\ %{}) do
    query = Tag

    query
    |> maybe_filter_by_titles(args)
  end

  defp maybe_filter_by_titles(query, args) do
    case Map.get(args, :titles) do
      titles when is_list(titles) ->
        from t in query, where: t.title in ^titles

      nil ->
        query
    end
  end
end
