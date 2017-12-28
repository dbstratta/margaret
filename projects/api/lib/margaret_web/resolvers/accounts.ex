defmodule MargaretWeb.Resolvers.Accounts do
  @moduledoc """
  The Account GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories}
  alias Stories.Story
  alias Accounts.User

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

  @doc """
  Resolves a connection of users.
  """
  def resolve_users(args, _), do: Relay.Connection.from_query(User, &Repo.all/1, args)

  @doc """
  Resolves a user creation.
  """
  def resolve_create_user(args, _) do
  end

  @doc """
  Resolves if the user is the viewer.
  """
  def resolve_is_viewer(%User{id: user_id}, _, %{context: %{viewer: %{id: viewer_id}}}) do
    {:ok, user_id === viewer_id}
  end

  def resolve_is_viewer(_, _), do: {:ok, false}
end
