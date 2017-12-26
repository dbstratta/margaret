defmodule MargaretWeb.Resolvers.Comments do
  @moduledoc """
  The Comment GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Stars, Comments}
  alias Comments.Comment

  @doc """
  Resolves the author of the comment.
  """
  def resolve_author(%Comment{author_id: author_id}, _, _) do
    {:ok, Accounts.get_user(author_id)}
  end

  @doc """
  Resolves the story of the comment.
  """
  def resolve_story(%Comment{story_id: story_id}, _, _) do
    {:ok, Stories.get_story(story_id)}
  end

  @doc """
  Resolves the parent comment of the comment.
  """
  def resolve_parent(%Comment{parent_id: nil}, _, _) do
    {:ok, nil}
  end

  def resolve_parent(%Comment{parent_id: parent_id}, _, _) do
    {:ok, Comments.get_comment(parent_id)}
  end

  @doc """
  Resolves the comments of the comment.
  """
  def resolve_comments(%Comment{id: parent_id}, args, _) do
    query = from c in Comment,
      where: c.parent_id == ^parent_id

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  def resolve_star_count(_, _, _) do
    {:ok, 3}
  end

  @doc """
  Resolves whether the viewer can star the comment or not.
  """
  def resolve_viewer_can_star(_, _, %{context: %{viewer: _viewer}}), do: {:ok, true}
  def resolve_viewer_can_star(_, _, _), do: {:ok, false}

  @doc """
  Resolves whether the viewer has starred this comment.
  """
  def resolve_viewer_has_starred(
    %Comment{id: comment_id}, _, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    {:ok, !!Stars.get_star(user_id: viewer_id, comment_id: comment_id)}
  end

  def resolve_viewer_has_starred(_, _, _), do: {:ok, false}

  @doc """
  Resolves the update of a comment.
  """
  def resolve_update_comment(
    %{comment_id: comment_id} = args, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    comment_id
    |> Comments.get_comment()
    |> do_resolve_update_comment(args, viewer_id)
  end

  def resolve_update_comment(_, _, _), do: Helpers.GraphQLErrors.unauthorized()

  defp do_resolve_update_comment(
    %Comment{author_id: author_id} = comment,
    args,
    viewer_id
  ) when author_id === viewer_id do
    case Comments.update_comment(comment, args) do
      {:ok, comment} -> {:ok, %{comment: comment}}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  defp do_resolve_update_comment(
    %Comment{author_id: author_id}, _, viewer_id
  ) when author_id !== viewer_id do
    Helpers.GraphQLErrors.unauthorized()
  end

  defp do_resolve_update_comment(nil, _, _), do: {:error, "Comment doesn't exist."}

  @doc """
  Resolves the deletion of a comment.
  """
  def resolve_delete_comment(
    %{comment_id: comment_id} = args, %{context: %{viewer: %{id: viewer_id}}}
  ) do
    
  end
end
