defmodule MargaretWeb.Resolvers.Comments do
  @moduledoc """
  The Comment GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Stars, Bookmarks, Comments}
  alias Accounts.User
  alias Comments.Comment
  alias Stars.Star

  @doc """
  Resolves the author of the comment.
  """
  def resolve_author(%Comment{author_id: author_id}, _, _),
    do: {:ok, Accounts.get_user(author_id)}

  @doc """
  Resolves the stargazers of the comment.
  """
  def resolve_stargazers(%Comment{id: comment_id}, args, _) do
    query =
      from(
        u in User,
        join: s in Star,
        on: s.user_id == u.id,
        where: is_nil(u.deactivated_at),
        where: s.comment_id == ^comment_id,
        select: {u, s.inserted_at}
      )

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    transform_edges =
      &Enum.map(&1, fn %{node: {user, starred_at}} = edge ->
        edge
        |> Map.put(:starred_at, starred_at)
        |> Map.update!(:node, fn _ -> user end)
      end)

    connection =
      connection
      |> Map.update!(:edges, transform_edges)
      |> Map.put(:total_count, Stars.get_star_count(%{comment_id: comment_id}))

    {:ok, connection}
  end

  @doc """
  Resolves the story of the comment.
  """
  def resolve_story(%Comment{story_id: story_id}, _, _), do: {:ok, Stories.get_story(story_id)}

  @doc """
  Resolves the parent comment of the comment.
  """
  def resolve_parent(%Comment{parent_id: nil}, _, _), do: {:ok, nil}

  def resolve_parent(%Comment{parent_id: parent_id}, _, _) do
    {:ok, Comments.get_comment(parent_id)}
  end

  @doc """
  Resolves the comments of the comment.
  """
  def resolve_comments(%Comment{id: comment_id}, args, _) do
    query = from(c in Comment, where: c.parent_id == ^comment_id)

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    connection =
      Map.put(connection, :total_count, Comments.get_comment_count(%{comment_id: comment_id}))

    {:ok, connection}
  end

  @doc """
  Resolves whether the viewer can star the comment.
  """
  def resolve_viewer_can_star(_, _, %{context: %{viewer: _viewer}}), do: {:ok, true}

  @doc """
  Resolves whether the viewer has starred this comment.
  """
  def resolve_viewer_has_starred(%Comment{id: comment_id}, _, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    {:ok, Stars.has_starred(%{user_id: viewer_id, comment_id: comment_id})}
  end

  @doc """
  Resolves whether the viewer can bookmark the comment.
  """
  def resolve_viewer_can_bookmark(_, _, %{context: %{viewer: _viewer}}), do: {:ok, true}

  @doc """
  Resolves whether the viewer has bookmarked this comment.
  """
  def resolve_viewer_has_bookmarked(%Comment{id: comment_id}, _, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    {:ok, Bookmarks.has_bookmarked(%{user_id: viewer_id, comment_id: comment_id})}
  end

  @doc """
  Resolves whether the viewer can comment the comment.
  """
  def resolve_viewer_can_comment(_, _, %{context: %{viewer: _viewer}}), do: {:ok, true}

  def resolve_viewer_can_update(%Comment{author_id: author_id}, _, %{
        context: %{viewer: %{id: author_id}}
      }) do
    {:ok, true}
  end

  def resolve_viewer_can_delete(%Comment{author_id: author_id}, _, %{
        context: %{viewer: %{id: author_id}}
      }) do
    {:ok, true}
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
      {:ok, comment} -> {:ok, %{comment: comment}}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  defp do_resolve_update_comment(%Comment{}, _, _), do: Helpers.GraphQLErrors.unauthorized()

  defp do_resolve_update_comment(nil, _, _), do: {:error, "Comment doesn't exist."}

  @doc """
  Resolves the deletion of a comment.
  """
  def resolve_delete_comment(%{comment_id: _comment_id} = _args, %{
        context: %{viewer: %{id: _viewer_id}}
      }) do
  end
end
