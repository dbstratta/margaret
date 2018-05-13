defmodule MargaretWeb.Resolvers.Comments do
  @moduledoc """
  The Comment GraphQL resolvers.
  """

  import Margaret.Helpers, only: [ok: 1]
  alias MargaretWeb.Helpers

  alias Margaret.{
    Stars,
    Bookmarks,
    Comments
  }

  alias Comments.Comment

  @doc """
  Resolves the author of the comment.
  """
  def resolve_author(comment, _, _) do
    comment
    |> Comments.author()
    |> ok()
  end

  @doc """
  Resolves the stargazers of the comment.
  """
  def resolve_stargazers(comment, args, _) do
    args
    |> Map.put(:comment, comment)
    |> Stars.stargazers()
  end

  @doc """
  Resolves the story of the comment.
  """
  def resolve_story(comment, _, _) do
    comment
    |> Comments.story()
    |> ok()
  end

  @doc """
  Resolves the parent comment of the comment.
  """
  def resolve_parent(comment, _, _) do
    comment
    |> Comments.parent()
    |> ok()
  end

  @doc """
  Resolves the comments of the comment.
  """
  def resolve_comments(parent, args, _) do
    args
    |> Map.put(:parent, parent)
    |> Comments.comments()
  end

  @doc """
  Resolves whether the viewer can star the comment.
  """
  def resolve_viewer_can_star(_, _, _), do: ok(true)

  @doc """
  Resolves whether the viewer has starred this comment.
  """
  def resolve_viewer_has_starred(comment, _, %{context: %{viewer: viewer}}) do
    [user: viewer, comment: comment]
    |> Stars.has_starred?()
    |> ok()
  end

  @doc """
  Resolves whether the viewer can bookmark the comment.
  """
  def resolve_viewer_can_bookmark(_, _, _), do: ok(true)

  @doc """
  Resolves whether the viewer has bookmarked this comment.
  """
  def resolve_viewer_has_bookmarked(comment, _, %{context: %{viewer: viewer}}) do
    [user: viewer, comment: comment]
    |> Bookmarks.has_bookmarked?()
    |> ok()
  end

  @doc """
  Resolves whether the viewer can comment the comment.
  """
  def resolve_viewer_can_comment(_, _, _), do: ok(true)

  def resolve_viewer_can_update(%Comment{author_id: author_id}, _, %{
        context: %{viewer: %{id: author_id}}
      }) do
    ok(true)
  end

  def resolve_viewer_can_delete(%Comment{author_id: author_id}, _, %{
        context: %{viewer: %{id: author_id}}
      }) do
    ok(true)
  end

  @doc """
  Resolves the update of a comment.
  """
  def resolve_update_comment(%{comment_id: comment_id} = args, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    comment_id
    |> Comments.get_comment()
    |> do_resolve_update_comment(args, viewer_id)
  end

  defp do_resolve_update_comment(%Comment{author_id: author_id} = comment, args, author_id) do
    case Comments.update_comment(comment, args) do
      {:ok, comment} -> ok(%{comment: comment})
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  defp do_resolve_update_comment(%Comment{}, _, _), do: Helpers.GraphQLErrors.unauthorized()

  defp do_resolve_update_comment(nil, _, _), do: Helpers.GraphQLErrors.comment_not_found()

  @doc """
  Resolves the deletion of a comment.
  """
  def resolve_delete_comment(%{comment_id: _comment_id} = _args, %{
        context: %{viewer: %{id: _viewer_id}}
      }) do
    Helpers.GraphQLErrors.not_implemented()
  end
end
