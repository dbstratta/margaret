defmodule MargaretWeb.Resolvers.Starrable do
  @moduledoc """
  The Starrable GraphQL resolvers.
  """

  alias Margaret.{Stories, Stars, Comments}
  alias Stories.Story
  alias Comments.Comment

  @doc """
  Resolves the star of a starrable.
  """
  def resolve_star(
    %{starrable_id: %{type: :story, id: story_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    story_id
    |> Stories.get_story()
    |> do_resolve_star(viewer_id)
  end

  def resolve_star(
    %{starrable_id: %{type: :comment, id: comment_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    comment_id
    |> Comments.get_comment()
    |> do_resolve_star(viewer_id)
  end

  defp do_resolve_star(%Story{id: story_id} = story, viewer_id) do
    Stars.insert_star(%{user_id: viewer_id, story_id: story_id})
    {:ok, %{starrable: story}}
  end

  defp do_resolve_star(%Comment{id: comment_id} = comment, viewer_id) do
    Stars.insert_star(%{user_id: viewer_id, comment_id: comment_id})
    {:ok, %{starrable: comment}}
  end

  defp do_resolve_star(nil, _), do: {:error, "Starrable doesn't exist."}

  @doc """
  Resolves the unstar of a starrable.
  """
  def resolve_unstar(
    %{starrable_id: %{type: :story, id: story_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    story_id
    |> Stories.get_story()
    |> do_resolve_unstar(viewer_id)
  end

  def resolve_unstar(
    %{starrable_id: %{type: :comment, id: comment_id}}, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    comment_id
    |> Comments.get_comment()
    |> do_resolve_unstar(viewer_id)
  end

  defp do_resolve_unstar(%Story{id: story_id} = story, viewer_id) do
    Stars.delete_star(user_id: viewer_id, story_id: story_id)
    {:ok, %{starrable: story}}
  end

  defp do_resolve_unstar(%Comment{id: comment_id} = comment, viewer_id) do
    Stars.delete_star(user_id: viewer_id, comment_id: comment_id)
    {:ok, %{starrable: comment}}
  end

  defp do_resolve_unstar(nil, _), do: {:error, "Starrable doesn't exist."}
end
