defmodule MargaretWeb.Resolvers.Accounts do
  @moduledoc """
  The Account GraphQL resolvers.
  """

  import Margaret.Helpers, only: [ok: 1]
  alias MargaretWeb.Helpers

  alias Margaret.{
    Accounts,
    Stories,
    Stars,
    Bookmarks,
    Follows,
    Notifications
  }

  alias Accounts.User

  @doc """
  Resolves the currently logged in user.
  """
  def resolve_viewer(_, %{context: %{viewer: viewer}}), do: ok(viewer)

  @doc """
  Resolves a user by its username.
  """
  def resolve_user(%{username: username}, _) do
    case Accounts.get_user_by_username(username) do
      %User{} = user -> ok(user)
      nil -> Helpers.GraphQLErrors.user_not_found()
    end
  end

  @doc """
  Resolves a connection of stories of a user.

  The author can see their unlisted stories and drafts,
  other users only can see their public stories.
  """
  def resolve_stories(author, args, _) do
    args
    |> Map.put(:author, author)
    |> Stories.stories()
  end

  @doc """
  Resolves the connection of followees of a user.
  """
  def resolve_followers(followee, args, _) do
    Accounts.followers(followee, args)
  end

  @doc """
  Resolves the connection of followees of a user.
  """
  def resolve_followees(follower, args, _) do
    args
    |> Map.put(:follower, follower)
    |> Follows.followees()
  end

  @doc """
  Resolves the connection of starrables the user starred.
  """
  def resolve_starred(user, args, _) do
    args
    |> Map.put(:user, user)
    |> Stars.starred()
  end

  @doc """
  Resolves the connection of bookmarkables the user bookmarked.

  Bookmarks are only visible to the user who bookmarked.
  """
  def resolve_bookmarked(user, args, %{context: %{viewer: viewer}}) do
    if user.id === viewer.id do
      args
      |> Map.put(:user, user)
      |> Bookmarks.bookmarked()
    else
      Helpers.GraphQLErrors.unauthorized()
    end
  end

  @doc """
  Resolves the publications of the user.
  """
  def resolve_publications(member, args, _) do
    Accounts.publications(member, args)
  end

  @doc """
  Resolves the notifications of the user.

  Only the currently authenticated user can see their
  notifications.
  """
  def resolve_notifications(user, args, %{context: %{viewer: viewer}}) do
    if user.id === viewer.id do
      args
      |> Map.put(:notified_user, user)
      |> Notifications.notifications()
    else
      Helpers.GraphQLErrors.unauthorized()
    end
  end

  @doc """
  Resolves a connection of users.
  """
  def resolve_users(args, _) do
    Accounts.users(args)
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
    attrs = %{now: NaiveDateTime.utc_now()}

    do_resolve_update_user(viewer, attrs)
  end

  defp do_resolve_update_user(user, attrs) do
    case Accounts.update_user(user, attrs) do
      {:ok, %User{} = viewer} -> ok(%{viewer: viewer})
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Resolves the mark of the viewer for deletion.
  """
  def resolve_mark_viewer_for_deletion(_, %{context: %{viewer: viewer}}) do
    case Accounts.mark_user_for_deletion(viewer) do
      {:ok, _} -> ok(%{viewer: viewer})
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Resolves if the user is the viewer.
  """
  def resolve_is_viewer(user, _, %{context: %{viewer: viewer}}) do
    user.id
    |> Kernel.===(viewer.id)
    |> ok()
  end

  @doc """
  Resolves if the viewer can follow the user.
  """
  def resolve_viewer_can_follow(user, _, %{context: %{viewer: viewer}}) do
    [follower: viewer, user: user]
    |> Follows.can_follow?()
    |> ok()
  end

  @doc """
  Resolves whether the viewer has followed this user.
  """
  def resolve_viewer_has_followed(user, _, %{context: %{viewer: viewer}}) do
    [follower: viewer, user: user]
    |> Follows.has_followed?()
    |> ok()
  end
end
