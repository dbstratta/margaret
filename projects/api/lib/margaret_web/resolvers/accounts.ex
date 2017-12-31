defmodule MargaretWeb.Resolvers.Accounts do
  @moduledoc """
  The Account GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Comments, Publications, Stars, Bookmarks}
  alias Accounts.{User, Follow}
  alias Stories.Story
  alias Comments.Comment
  alias Publications.{Publication, PublicationMembership}
  alias Stars.Star
  alias Bookmarks.Bookmark

  @doc """
  Resolves the currently logged in user.
  """
  def resolve_viewer(_, %{context: %{viewer: viewer}}), do: {:ok, viewer}

  @doc """
  Resolves a user by its username.
  """
  def resolve_user(%{username: username}, _), do: {:ok, Accounts.get_user_by_username(username)}
  def resolve_user(%Story{author_id: author_id}, _, _), do: {:ok, Accounts.get_user(author_id)}

  @doc """
  Resolves a connection of stories of a user.

  The author can see their unlisted stories and drafts,
  other users only can see their public stories.
  """
  def resolve_stories(
    %User{id: author_id}, args, %{context: %{viewer: %{id: viewer_id}}}
  ) when author_id === viewer_id do
    query = from s in Story,
      where: s.author_id == ^author_id

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  def resolve_stories(%User{id: author_id}, args, _) do
    query = from s in Story,
      where: s.author_id == ^author_id,
      where: s.publish_status == ^:public

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  @doc """
  Resolves the connection of followees of a user.

  Also resolves the `followed_at` attribute.
  """
  def resolve_followers(%User{id: user_id}, args, _) do
    query = from u in User,
      join: f in Follow, on: f.follower_id == u.id,
      where: f.user_id == ^user_id,
      select: {u, f.inserted_at}

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    transform_edges = &Enum.map &1, fn %{node: {node, followed_at}} = edge ->
      edge
      |> Map.put(:followed_at, followed_at)
      |> Map.update!(:node, fn _ -> node end)
    end

    connection =
      connection
      |> Map.update!(:edges, transform_edges)
      |> Map.put(:total_count, Accounts.get_follower_count(%{user_id: user_id}))

    {:ok, connection}
  end

  @doc """
  Resolves the connection of followees of a user.
  """
  def resolve_followees(%User{id: user_id}, args, _) do
    query = from f in Follow,
      left_join: u in User, on: u.id == f.user_id,
      left_join: p in Publication, on: p.id == f.publication_id,
      where: f.follower_id == ^user_id,
      select: {u, p, f.inserted_at}

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    transform_edges = &Enum.map &1, fn
      %{node: {user, nil, followed_at}} = edge ->
        edge
        |> Map.put(:followed_at, followed_at)
        |> Map.update!(:node, fn _ -> user end)

      %{node: {nil, publication, followed_at}} = edge ->
        edge
        |> Map.put(:followed_at, followed_at)
        |> Map.update!(:node, fn _ -> publication end)
    end

    connection =
      connection
      |> Map.update!(:edges, transform_edges)
      |> Map.put(:total_count, Accounts.get_followee_count(user_id))

    {:ok, connection}
  end

  @doc """
  Resolves the connection of starrables the user starred.
  """
  def resolve_starred(%User{id: user_id}, args, _) do
    query = from star in Star,
      left_join: story in Story, on: story.id == star.story_id,
      left_join: comment in Comment, on: comment.id == star.comment_id,
      where: star.user_id == ^user_id,
      select: {story, comment, star.inserted_at}

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    transform_edges = &Enum.map &1, fn
      %{node: {story, nil, starred_at}} = edge ->
        edge
        |> Map.put(:followed_at, starred_at)
        |> Map.update!(:node, fn _ -> story end)

      %{node: {nil, comment, starred_at}} = edge ->
        edge
        |> Map.put(:followed_at, starred_at)
        |> Map.update!(:node, fn _ -> comment end)
    end

    connection =
      connection
      |> Map.update!(:edges, transform_edges)
      |> Map.put(:total_count, Stars.get_starred_count(user_id))

    {:ok, connection}
  end

  @doc """
  Resolves the connection of bookmarkables the user bookmarked.

  Bookmarks are only visible to the user who bookmarked.
  """
  def resolve_bookmarked( %User{id: user_id}, args, %{context: %{viewer: %{id: user_id}}}) do
    query = from b in Bookmark,
      left_join: s in Story, on: s.id == b.story_id,
      left_join: c in Comment, on: c.id == b.comment_id,
      where: b.user_id == ^user_id,
      select: {s, c, b.inserted_at}

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    transform_edges = &Enum.map &1, fn
      %{node: {story, nil, bookmarked_at}} = edge ->
        edge
        |> Map.put(:followed_at, bookmarked_at)
        |> Map.update!(:node, fn _ -> story end)

      %{node: {nil, comment, bookmarked_at}} = edge ->
        edge
        |> Map.put(:followed_at, bookmarked_at)
        |> Map.update!(:node, fn _ -> comment end)
    end

    connection =
      connection
      |> Map.update!(:edges, transform_edges)
      |> Map.put(:total_count, Bookmarks.get_bookmarked_count(user_id))

    {:ok, connection}
  end

  def resolve_bookmarked(_, _, _), do: {:ok, nil}

  def resolve_publication(%User{id: user_id}, %{name: publication_name}, _) do
    query = from p in Publication,
      join: pm in PublicationMembership, on: pm.publication_id == p.id,
      where: pm.member_id == ^user_id and p.name == ^publication_name

    {:ok, Repo.one(query)}
  end

  def resolve_publications(%User{id: user_id}, args, _) do
    query = from p in Publication,
      join: pm in PublicationMembership, on: pm.publication_id == p.id,
      where: pm.member_id == ^user_id,
      select: {p, pm.role, pm.inserted_at}

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    transform_edges = &Enum.map &1, fn %{node: {node, role, member_since}} = edge ->
      edge
      |> Map.put(:member_since, member_since)
      |> Map.put(:role, role)
      |> Map.update!(:node, fn _ -> node end)
    end

    connection =
      connection
      |> Map.update!(:edges, transform_edges)
      |> Map.put(:total_count, Accounts.get_publication_count(user_id))

    {:ok, connection}
  end

  def resolve_notifications(
    %User{id: user_id}, _, %{context: %{viewer: %{id: viewer_id}}}
  ) when user_id !== viewer_id do
    {:ok, nil}
  end

  def resolve_notifications(_, _), do: {:ok, nil}

  @doc """
  Resolves a connection of users.
  """
  def resolve_users(args, _) do
    {:ok, connection} = Relay.Connection.from_query(User, &Repo.all/1, args)

    connection = Map.put(connection, :total_count, Accounts.get_user_count())

    {:ok, connection}
  end

  @doc """
  Resolves a user creation.
  """
  def resolve_create_user(_args, _) do
  end

  @doc """
  Resolves a user update.
  """
  def resolve_update_user(_args, %{context: %{viewer: _viewer}}) do
    Helpers.GraphQLErrors.not_implemented()
  end

  @doc """
  Resolves if the user is the viewer.
  """
  def resolve_is_viewer(
    %User{id: user_id}, _, %{context: %{viewer: %{id: viewer_id}}}
  ) when user_id === viewer_id do
    {:ok, true}
  end

  def resolve_viewer_can_follow(
    %User{id: user_id}, _, %{context: %{viewer: %{id: viewer_id}}}
  ) when user_id === viewer_id do
    {:ok, false}
  end

  def resolve_viewer_can_follow(
    %User{id: user_id}, _, %{context: %{viewer: %{id: viewer_id}}}
  ) when user_id !== viewer_id do
    {:ok, true}
  end

  def resolve_viewer_has_followed(%User{id: user_id}, _, %{context: %{viewer: %{id: viewer_id}}}) do
    case Accounts.get_follow(follower_id: viewer_id, user_id: user_id) do
      %Follow{} -> {:ok, true}
      _ -> {:ok, false}
    end
  end
end
