defmodule MargaretWeb.Resolvers.Bookmarkable do
  @moduledoc """
  The Bookmarkable GraphQL resolvers.
  TODO: See if I can refactor this into something prettier.
  """

  alias Margaret.{Stories, Comments, Bookmarks}
  alias Stories.Story
  alias Comments.Comment

  def resolve_bookmark(%{bookmarkable_id: %{type: :story, id: story_id}}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    story_id
    |> Stories.get_story()
    |> do_resolve_bookmark(viewer_id)
  end

  def resolve_bookmark(%{bookmarkable_id: %{type: :comment, id: comment_id}}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    comment_id
    |> Comments.get_comment()
    |> do_resolve_bookmark(viewer_id)
  end

  defp do_resolve_bookmark(%Story{id: story_id} = story, viewer_id) do
    Bookmarks.insert_bookmark(%{user_id: viewer_id, story_id: story_id})
    {:ok, %{bookmarkable: story}}
  end

  defp do_resolve_bookmark(%Comment{id: comment_id} = comment, viewer_id) do
    Bookmarks.insert_bookmark(%{user_id: viewer_id, comment_id: comment_id})
    {:ok, %{bookmarkable: comment}}
  end

  defp do_resolve_bookmark(nil, _), do: {:error, "Bookmarkable doesn't exist."}

  def resolve_unbookmark(%{bookmarkable_id: %{type: :story, id: story_id}}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    story_id
    |> Stories.get_story()
    |> do_resolve_unbookmark(viewer_id)
  end

  def resolve_unbookmark(%{bookmarkable_id: %{type: :comment, id: comment_id}}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    comment_id
    |> Comments.get_comment()
    |> do_resolve_unbookmark(viewer_id)
  end

  defp do_resolve_unbookmark(%Story{id: story_id} = story, viewer_id) do
    Bookmarks.delete_bookmark(%{user_id: viewer_id, story_id: story_id})
    {:ok, %{bookmarkable: story}}
  end

  defp do_resolve_unbookmark(%Comment{id: comment_id} = comment, viewer_id) do
    Bookmarks.delete_bookmark(%{user_id: viewer_id, comment_id: comment_id})
    {:ok, %{bookmarkable: comment}}
  end

  defp do_resolve_unbookmark(nil, _), do: {:error, "Bookmarkable doesn't exist."}
end
