defmodule MargaretWeb.Resolvers.Accounts do
  @moduledoc """
  The Account GraphQL resolvers.
  TODO: Try to clean up queries using defined API instead.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers

  alias Margaret.{
    Repo,
    Accounts,
    Follows,
    Stories,
    Comments,
    Publications,
    Stars,
    Bookmarks,
    Notifications
  }

  alias Accounts.User
  alias Follows.Follow
  alias Stories.Story
  alias Comments.Comment
  alias Publications.{Publication, PublicationMembership}
  alias Stars.Star
  alias Bookmarks.Bookmark
  alias Notifications.{Notification, UserNotification}

  @doc """
  Resolves the currently logged in user.
  """
  def resolve_viewer(_, %{context: %{viewer: viewer}}), do: {:ok, viewer}

  @doc """
  Resolves a user by its username.
  """
  def resolve_user(%{username: username}, _) do
    user = Accounts.get_user_by_username(username)

    {:ok, user}
  end

  @doc """
  Resolves a connection of stories of a user.

  The author can see their unlisted stories and drafts,
  other users only can see their public stories.
  """
  def resolve_stories(%User{id: author_id} = user, args, %{context: %{viewer: %{id: author_id}}}) do
    query = Story.by_author(user)
    total_count = Accounts.get_story_count(user)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  def resolve_stories(user, args, _) do
    query =
      user
      |> Story.by_author()
      |> Story.public()

    total_count = Accounts.get_story_count(user, public_only: true)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves the connection of followees of a user.

  Also resolves the `followed_at` attribute.
  """
  def resolve_followers(%User{id: user_id} = user, args, _) do
    query =
      from(
        u in User,
        join: f in Follow,
        on: f.follower_id == u.id,
        where: is_nil(u.deactivated_at),
        where: f.user_id == ^user_id,
        select: {u, %{followed_at: f.inserted_at}}
      )

    total_count = Accounts.get_follower_count(user)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves the connection of followees of a user.
  """
  def resolve_followees(%User{id: user_id} = user, args, _) do
    query =
      from(
        f in Follow,
        left_join: u in User,
        on: u.id == f.user_id,
        left_join: p in Publication,
        on: p.id == f.publication_id,
        where: f.follower_id == ^user_id,
        where: is_nil(u.deactivated_at),
        select: {[u, p], %{followed_at: f.inserted_at}}
      )

    total_count = Follows.get_followee_count(user)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves the connection of starrables the user starred.
  """
  def resolve_starred(%User{id: user_id} = user, args, _) do
    query =
      from(
        star in Star,
        left_join: story in Story,
        on: story.id == star.story_id,
        left_join: comment in Comment,
        on: comment.id == star.comment_id,
        where: star.user_id == ^user_id,
        select: {[story, comment], %{starred_at: star.inserted_at}}
      )

    total_count = Stars.get_starred_count(user)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves the connection of bookmarkables the user bookmarked.

  Bookmarks are only visible to the user who bookmarked.
  """
  def resolve_bookmarked(%User{id: user_id} = user, args, %{context: %{viewer: %{id: user_id}}}) do
    query =
      from(
        b in Bookmark,
        left_join: s in Story,
        on: s.id == b.story_id,
        left_join: c in Comment,
        on: c.id == b.comment_id,
        where: b.user_id == ^user_id,
        select: {[s, c], %{bookmarked_at: b.inserted_at}}
      )

    total_count = Bookmarks.get_bookmarked_count(user)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  def resolve_bookmarked(_, _, _), do: {:ok, nil}

  @doc """
  Resolves a publication of the user.
  """
  def resolve_publication(%User{id: user_id}, %{name: publication_name}, _) do
    query =
      from(
        p in Publication,
        join: pm in PublicationMembership,
        on: pm.publication_id == p.id,
        where: pm.member_id == ^user_id and p.name == ^publication_name
      )

    publication = Repo.one(query)

    {:ok, publication}
  end

  @doc """
  Resolves the publications of the user.
  """
  def resolve_publications(%User{id: user_id} = user, args, _) do
    query =
      from(
        p in Publication,
        join: pm in PublicationMembership,
        on: pm.publication_id == p.id,
        where: pm.member_id == ^user_id,
        select: {p, %{role: pm.role, member_since: pm.inserted_at}}
      )

    total_count = Accounts.get_publication_count(user)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves the notifications of the user.
  """
  def resolve_notifications(%User{id: user_id} = user, args, %{context: %{viewer: %{id: user_id}}}) do
    query =
      from(
        n in Notification,
        join: un in UserNotification,
        on: un.notification_id == n.id,
        where: un.user_id == ^user_id
      )

    total_count = Notifications.get_notification_count(user)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  def resolve_notifications(_, _, _), do: {:ok, nil}

  @doc """
  Resolves a connection of users.
  """
  def resolve_users(args, _) do
    query = User.active()
    total_count = Accounts.get_user_count()

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves a user creation.
  """
  def resolve_create_user(_args, _) do
  end

  @doc """
  Resolves the update of the viewer.
  """
  def resolve_update_viewer(attrs, %{context: %{viewer: viewer}}) do
    do_resolve_update_user(viewer, attrs)
  end

  @doc """
  Resolves teh deactivation of the user.
  """
  def resolve_deactivate_viewer(_, %{context: %{viewer: viewer}}) do
    now = NaiveDateTime.utc_now()

    do_resolve_update_user(viewer, %{deactivated_at: now})
  end

  defp do_resolve_update_user(user, attrs) do
    case Accounts.update_user(user, attrs) do
      {:ok, %User{} = viewer} -> {:ok, %{viewer: viewer}}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def resolve_mark_viewer_for_deletion(_, %{context: %{viewer: viewer}}) do
    case Accounts.mark_user_for_deletion(viewer) do
      {:ok, _} -> {:ok, %{viewer: viewer}}
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Resolves if the user is the viewer.
  """
  def resolve_is_viewer(%User{id: user_id}, _, %{context: %{viewer: %{id: user_id}}}) do
    {:ok, true}
  end

  def resolve_is_viewer(_, _, _), do: {:ok, false}

  @doc """
  Resolves if the viewer can follow the user.
  """
  def resolve_viewer_can_follow(%User{id: user_id}, _, %{context: %{viewer: %{id: user_id}}}) do
    {:ok, false}
  end

  def resolve_viewer_can_follow(_, _, _), do: {:ok, true}

  @doc """
  Resolves whether the viewer has followed this user.
  """
  def resolve_viewer_has_followed(user, _, %{context: %{viewer: viewer}}) do
    has_followed = Follows.has_followed?(follower: viewer, user: user)

    {:ok, has_followed}
  end
end
