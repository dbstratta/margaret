defmodule MargaretWeb.Resolvers.Comments do
  @moduledoc """
  The Comment GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Stars, Publications, Comments}
  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment

  def resolve_author(%Comment{author_id: author_id}, _, _) do
    {:ok, Accounts.get_user(author_id)}
  end

  def resolve_story(%Comment{story_id: story_id}, _, _) do
    {:ok, Stories.get_story(story_id)}
  end

  def resolve_parent(%Comment{parent_id: nil}, _, _) do
    {:ok, nil}
  end

  def resolve_parent(%Comment{parent_id: parent_id}, _, _) do
    {:ok, Comments.get_comment(parent_id)}
  end

  def resolve_comments(%Comment{id: parent_id}, args, _) do
    query = from c in Comment,
      where: c.parent_id == ^parent_id

    Relay.Connection.from_query(query, &Repo.all/1, args)
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
end
