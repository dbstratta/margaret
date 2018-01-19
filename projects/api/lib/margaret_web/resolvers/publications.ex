defmodule MargaretWeb.Resolvers.Publications do
  @moduledoc """
  The Publication GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Publications}
  alias Accounts.{User, Follow}
  alias Stories.Story
  alias Publications.{Publication, PublicationMembership, PublicationInvitation}

  @doc """
  Resolves a publication.
  """
  def resolve_publication(%{name: name}, _) do
    {:ok, Publications.get_publication_by_name(name)}
  end

  @doc """
  Resolves the owner of the publication.
  """
  def resolve_owner(%Publication{id: publication_id}, _, _) do
    {:ok, Publications.get_publication_owner(publication_id)}
  end

  @doc """
  Resolves the members of the publication.
  """
  def resolve_members(%Publication{id: publication_id}, args, _) do
    query =
      from(
        u in User,
        join: pm in PublicationMembership,
        on: pm.member_id == u.id,
        where: is_nil(u.deactivated_at),
        where: pm.publication_id == ^publication_id,
        select: {u, pm.role, pm.inserted_at}
      )

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    transform_edges =
      &Enum.map(&1, fn %{node: {node, role, member_since}} = edge ->
        edge
        |> Map.put(:role, role)
        |> Map.put(:member_since, member_since)
        |> Map.update!(:node, fn _ -> node end)
      end)

    connection =
      connection
      |> Map.update!(:edges, transform_edges)
      |> Map.put(:total_count, Publications.get_member_count(publication_id))

    {:ok, connection}
  end

  @doc """
  Resolves the stories published under the publication.
  """
  def resolve_stories(%Publication{id: publication_id}, args, _) do
    query = from(s in Story, where: s.publication_id == ^publication_id)

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    connection = Map.put(connection, :total_count, Publications.get_story_count(publication_id))

    {:ok, connection}
  end

  @doc """
  Resolves the followers of the publication.
  """
  def resolve_followers(%Publication{id: publication_id}, args, _) do
    query =
      from(
        u in User,
        join: f in Follow,
        on: f.follower_id == u.id,
        where: is_nil(u.deactivated_at),
        where: f.publication_id == ^publication_id,
        select: {u, f.inserted_at}
      )

    {:ok, connection} = Relay.Connection.from_query(query, &Repo.all/1, args)

    transform_edges =
      &Enum.map(&1, fn %{node: {node, followed_at}} = edge ->
        edge
        |> Map.put(:followed_at, followed_at)
        |> Map.update!(:node, fn _ -> node end)
      end)

    connection =
      connection
      |> Map.update!(:edges, transform_edges)
      |> Map.put(:total_count, Accounts.get_follower_count(%{publication_id: publication_id}))

    {:ok, connection}
  end

  def resolve_tags(%Publication{} = publication, _, _) do
    tags =
      publication
      |> Repo.preload(:tags)
      |> Map.get(:tags)

    {:ok, tags}
  end

  @doc """
  Resolves the invitations sent by the publication.
  """
  def resolve_membership_invitations(%Publication{id: publication_id}, args, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    publication_id
    |> Publications.can_see_invitations?(viewer_id)
    |> do_resolve_membership_invitations(publication_id, args)
  end

  defp do_resolve_membership_invitations(true, publication_id, args) do
    query = from(pi in PublicationInvitation, where: pi.publication_id == ^publication_id)

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  defp do_resolve_membership_invitations(false, _, _), do: {:ok, nil}

  @doc """
  Resolves whether the user is a member of the publication.
  """
  def resolve_viewer_is_a_member(%{id: publication_id}, _, %{context: %{viewer: viewer}}) do
    {:ok, Publications.publication_member?(publication_id, viewer.id)}
  end

  @doc """
  Resolves whether the user can administer the publication.
  """
  def resolve_viewer_can_administer(%{id: publication_id}, _, %{context: %{viewer: viewer}}) do
    {:ok, Publications.publication_admin?(publication_id, viewer.id)}
  end

  @doc """
  Resolves whether the user can follow the publication.
  """
  def resolve_viewer_can_follow(_, _, %{context: %{viewer: _viewer}}), do: {:ok, true}

  @doc """
  Resolves whether the user has followd the publication.
  """
  def resolve_viewer_has_followed(%Publication{id: publication_id}, _, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    {:ok, Accounts.get_follow(%{follower_id: viewer_id, publication_id: publication_id})}
  end

  @doc """
  Resolves the creation of a publication.
  """
  def resolve_create_publication(args, %{context: %{viewer: %{id: viewer_id}}}) do
    args
    |> Map.put(:owner_id, viewer_id)
    |> Publications.insert_publication()
    |> case do
      {:ok, %{publication: publication}} -> {:ok, %{publication: publication}}
      {:error, reason} -> {:error, reason}
      {:error, _, reason, _} -> {:error, reason}
    end
  end

  @doc """
  Resolves the update of a publication.
  """
  def resolve_update_publication(%{publication_id: publication_id} = args, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    args = Map.delete(args, :publication_id)

    publication_id
    |> Publications.can_update_publication?(viewer_id)
    |> do_resolve_update_publication(publication_id, args)
  end

  defp do_resolve_update_publication(true, publication_id, attrs) do
    publication_id
    |> Publications.get_publication()
    |> do_resolve_update_publication(attrs)
  end

  defp do_resolve_update_publication(false, _, _), do: Helpers.GraphQLErrors.unauthorized()

  defp do_resolve_update_publication(%Publication{} = publication, attrs) do
    case Publications.update_publication(publication, attrs) do
      {:ok, %{publication: publication}} -> {:ok, %{publication: publication}}
      {:error, _, reason, _} -> {:error, reason}
    end
  end

  defp do_resolve_update_publication(nil, _), do: Helpers.GraphQLErrors.publication_doesnt_exist()

  @doc """
  Resolves the kick of a publication member.
  """
  def resolve_kick_member(%{member_id: member_id} = args, resolution) when is_binary(member_id) do
    args
    |> Map.update!(:member_id, &String.to_integer(&1))
    |> resolve_kick_member(resolution)
  end

  def resolve_kick_member(%{member_id: member_id}, %{context: %{viewer: %{id: member_id}}}) do
    {:error, "You can't kick yourself."}
  end

  def resolve_kick_member(%{member_id: member_id, publication_id: publication_id}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    publication_id
    |> Publications.publication_admin?(viewer_id)
    |> do_resolve_kick_member(publication_id, member_id)
  end

  defp do_resolve_kick_member(true, publication_id, member_id) do
    case Publications.kick_publication_member(publication_id, member_id) do
      {:ok, _} -> {:ok, %{publication: Publications.get_publication(publication_id)}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp do_resolve_kick_member(_, _, _), do: Helpers.GraphQLErrors.unauthorized()

  def resolve_delete_publication(_, _) do
    Helpers.GraphQLErrors.not_implemented()
  end

  @doc """
  Resolves the leave of the viewer from the publication.
  """
  def resolve_leave_publication(%{publication_id: publication_id}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    publication_id
    |> Publications.publication_owner?(viewer_id)
    |> do_resolve_leave_publication(publication_id, viewer_id)
  end

  defp do_resolve_leave_publication(true, _publication_id, _member_id) do
  end

  defp do_resolve_leave_publication(false, publication_id, member_id) do
    case Publications.delete_publication_membership(publication_id, member_id) do
      {:ok, _} -> {:ok, %{publication: Publications.get_publication(publication_id)}}
      {:error, reason} -> {:error, reason}
    end
  end
end
