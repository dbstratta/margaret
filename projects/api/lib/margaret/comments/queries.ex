defmodule Margaret.Comments.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{Accounts, Stories, Comments}
  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment

  def comments(args \\ %{}) do
    query = Comment

    query
    |> maybe_filter_by_commentable(args)
    |> maybe_filter_by_author(args)
  end

  defp maybe_filter_by_commentable(query, %{parent: %Comment{id: parent_id}}),
    do: from(c in query, where: c.parent_id == ^parent_id)

  defp maybe_filter_by_commentable(query, %{story: %Story{id: story_id}}),
    do: from(c in query, where: c.story_id == ^story_id)

  defp maybe_filter_by_commentable(query, _args), do: query

  defp maybe_filter_by_author(query, args) do
    case Map.get(args, :author) do
      %User{id: author_id} ->
        from c in query,
          where: c.author_id == ^author_id

      nil ->
        query
    end
  end
end
