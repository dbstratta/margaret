defmodule MargaretWeb.Resolvers.Accounts do
  @moduledoc """
  The Account GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Publications, Stars}
  alias Accounts.{User, Follow}
  alias Stories.Story
  alias Publications.{Publication, PublicationMembership}
  alias Stars.Star

  @doc """
  Resolves the currently logged in user.
  """
  def resolve_viewer(_, %{context: %{viewer: viewer}}), do: {:ok, viewer}
  def resolve_viewer(_, _), do: {:ok, nil}

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

  def resolve_followers(%User{id: user_id}, args, _) do
    query = from u in User,
      join: f in Follow, on: f.follower_id == u.id,
      where: f.user_id == ^user_id

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  def resolve_followees(%User{id: user_id}, args, _) do
    query = from u in User,
      join: f in Follow, on: f.user_id == u.id,
      where: f.follower_id == ^user_id

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  def resolve_starred_stories(%User{id: user_id}, args, _) do
    query = from story in Story,
      join: star in Star, on: star.story_id == story.id,
      where: star.user_id == ^user_id

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  def resolve_publication(%User{id: user_id}, %{name: publication_name}, _) do
    query = from p in Publication,
      join: pm in PublicationMembership, on: pm.publication_id == p.id,
      where: pm.member_id == ^user_id and p.name == ^publication_name

    {:ok, Repo.one(query)}
  end

  def resolve_publications(%User{id: user_id}, args, _) do
    query = from p in Publication,
      join: pm in PublicationMembership, on: pm.publication_id == p.id,
      where: pm.member_id == ^user_id

    Relay.Connection.from_query(query, &Repo.all/1, args)
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
  def resolve_users(args, _), do: Relay.Connection.from_query(User, &Repo.all/1, args)

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

  def resolve_update_user(_, _), do: Helpers.GraphQLErrors.unauthorized()

  @doc """
  Resolves if the user is the viewer.
  """
  def resolve_is_viewer(
    %User{id: user_id}, _, %{context: %{viewer: %{id: viewer_id}}}
  ) when user_id === viewer_id do
    {:ok, true}
  end

  def resolve_is_viewer(_, _, _), do: {:ok, false}

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

  def resolve_viewer_can_follow(_, _, _), do: {:ok, false}

  def resolve_viewer_has_followed(%User{id: user_id}, _, %{context: %{viewer: %{id: viewer_id}}}) do
    case Accounts.get_follow(follower_id: viewer_id, user_id: user_id) do
      %Follow{} -> {:ok, true}
      _ -> {:ok, false}
    end
  end

  def resolve_viewer_has_followed(_, _, _), do: {:ok, false}
end
