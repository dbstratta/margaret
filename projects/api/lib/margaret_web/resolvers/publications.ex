defmodule MargaretWeb.Resolvers.Publications do
  @moduledoc """
  The Publication GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Publications, Follows}
  alias Accounts.User
  alias Stories.Story
  alias Publications.{Publication, PublicationMembership, PublicationInvitation}
  alias Follows.Follow

  @doc """
  Resolves a publication.
  """
  def resolve_publication(%{name: name}, _) do
    publication = Publications.get_publication_by_name(name)

    {:ok, publication}
  end

  @doc """
  Resolves the owner of the publication.
  """
  def resolve_owner(publication, _, _) do
    owner = Publications.get_owner(publication)

    {:ok, owner}
  end

  @doc """
  Resolves the members of the publication.
  """
  def resolve_members(%Publication{id: publication_id} = publication, args, _) do
    query =
      from(
        u in User,
        join: pm in PublicationMembership,
        on: pm.member_id == u.id,
        where: is_nil(u.deactivated_at),
        where: pm.publication_id == ^publication_id,
        select: {u, %{role: pm.role, member_since: pm.inserted_at}}
      )

    total_count = Publications.get_member_count(publication)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves the stories published under the publication.
  """
  def resolve_stories(%Publication{id: publication_id} = publication, args, _) do
    query = from(s in Story, where: s.publication_id == ^publication_id)

    total_count = Publications.get_story_count(publication)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
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
        select: {u, %{followed_at: f.inserted_at}}
      )

    total_count = Follows.get_follower_count(%{publication_id: publication_id})

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves the tags of the publication.
  """
  def resolve_tags(%Publication{} = publication, _, _) do
    tags = Publications.get_tags(publication)

    {:ok, tags}
  end

  @doc """
  Resolves the invitations sent by the publication.
  """
  def resolve_membership_invitations(%Publication{id: publication_id} = publication, args, %{
        context: %{viewer: viewer}
      }) do
    publication
    |> Publications.can_see_invitations?(viewer)
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
  def resolve_viewer_is_a_member(publication, _, %{context: %{viewer: viewer}}) do
    is_member = Publications.member?(publication, viewer)

    {:ok, is_member}
  end

  @doc """
  Resolves whether the user can administer the publication.
  """
  def resolve_viewer_can_administer(publication, _, %{context: %{viewer: viewer}}) do
    can_administer = Publications.admin?(publication, viewer)

    {:ok, can_administer}
  end

  @doc """
  Resolves whether the user can follow the publication.
  """
  def resolve_viewer_can_follow(_, _, %{context: %{viewer: _viewer}}), do: {:ok, true}

  @doc """
  Resolves whether the user has followd the publication.
  TODO: Refactor this.
  """
  def resolve_viewer_has_followed(publication, _, %{context: %{viewer: viewer}}) do
    has_followed = Follows.has_followed?(follower: viewer, publication: publication)

    {:ok, has_followed}
  end

  @doc """
  Resolves the creation of a publication.
  TODO: Refactor this.
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
  TODO: Refactor this.
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
    {:error, "You can't kick yourself"}
  end

  def resolve_kick_member(args, %{context: %{viewer: viewer}}) do
    %{member_id: member_id, publication_id: publication_id} = args

    publication_id
    |> Publications.get_publication()
    |> do_resolve_kick_member(member_id, viewer)
  end

  defp do_resolve_kick_member(%Publication{} = publication, member_id, kicker) do
    with %User{} = user <- Accounts.get_user(member_id),
         true <- Publications.can_kick?(publication, kicker, user),
         {:ok, _} <- Publications.kick_member(publication, user) do
      {:ok, %{publication: publication}}
    else
      nil -> Helpers.GraphQLErrors.user_doesnt_exist()
      false -> Helpers.GraphQLErrors.unauthorized()
      {:error, _reason} = error -> error
    end
  end

  defp do_resolve_kick_member(nil = _publication, _member_id, _kicker),
    do: Helpers.GraphQLErrors.publication_doesnt_exist()

  @doc """
  Resolves the deletion of a publication.
  TODO: Implement this.
  """
  def resolve_delete_publication(_, _) do
    Helpers.GraphQLErrors.not_implemented()
  end

  @doc """
  Resolves the leave of the viewer from the publication.
  TODO: Refactor this.
  """
  def resolve_leave_publication(%{publication_id: publication_id}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    publication_id
    |> Publications.owner?(viewer_id)
    |> do_resolve_leave_publication(publication_id, viewer_id)
  end

  defp do_resolve_leave_publication(true, _publication_id, _member_id) do
  end

  defp do_resolve_leave_publication(false, publication_id, member_id) do
    case Publications.delete_membership(publication_id, member_id) do
      {:ok, _} -> {:ok, %{publication: Publications.get_publication(publication_id)}}
      {:error, reason} -> {:error, reason}
    end
  end
end
