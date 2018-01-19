defmodule MargaretWeb.Resolvers.Commentable do
  @moduledoc """
  The Commentable GraphQL resolvers.
  """

  alias Margaret.Comments
  alias Comments.Comment

  def resolve_comment(%{commentable_id: %{type: :comment, id: parent_id}, content: content}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    case Comments.get_comment(parent_id) do
      %Comment{story_id: story_id} ->
        do_resolve_comment(%{
          content: content,
          story_id: story_id,
          parent_id: parent_id,
          author_id: viewer_id
        })

      _ ->
        {:error, "The parent comment doesn't exist."}
    end
  end

  def resolve_comment(%{commentable_id: %{type: :story, id: story_id}, content: content}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    do_resolve_comment(%{content: content, story_id: story_id, author_id: viewer_id})
  end

  defp do_resolve_comment(attrs) do
    case Comments.create_comment(attrs) do
      {:ok, comment} -> {:ok, %{comment: comment}}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end
end
