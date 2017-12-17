defmodule MargaretWeb.Resolvers.Publications do
  @moduledoc """
  The Publication GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Publications}
  alias Accounts.User
  alias Stories.Story
  alias Publications.PublicationMembership

  def resolve_publication(%{name: name}, _) do
    {:ok, Publications.get_publication_by_name(name)}
  end

  def resolve_owner(%{id: publication_id}, _, _) do
    {:ok, Publications.get_publication_owner(publication_id)}
  end

  def resolve_member(%{id: publication_id}, %{member_id: %{id: member_id}}, _) do
    {
      :ok,
      Publications.get_publication_membership_by_publication_and_member(
        publication_id, member_id)
    }
  end

  def resolve_members(%{id: publication_id}, args, _) do
    query = from u in User,
      join: pm in PublicationMembership, on: pm.member_id == u.id,
      where: pm.publication_id == ^publication_id,
      select: u

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  def resolve_member_role(_, _, _) do
    {:ok, "Not implemented yet"}
  end

  def resolve_stories(%{id: publication_id}, args, _) do
    query = from s in Story, where: s.publication_id == ^publication_id

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  @doc """
  Resolves if the user is a member of the publication.
  """
  def resolve_viewer_is_a_member(_, _, %{context: %{user: nil}}), do: {:ok, false}

  def resolve_viewer_is_a_member(%{id: publication_id}, _, %{context: %{user: user}}) do
    {:ok, Publications.is_publication_member?(publication_id, user.id)}
  end

  @doc """
  Resolves if the user can administer the publication.
  """
  def resolve_viewer_can_administer(_, _, %{context: %{user: nil}}), do: {:ok, false}

  def resolve_viewer_can_administer(%{id: publication_id}, _, %{context: %{user: user}}) do
    {:ok, Publications.is_publication_admin?(publication_id, user.id)}
  end

  def resolve_create_publication(_, %{context: %{user: nil}}) do
    Helpers.GraphQLErrors.unauthorized()
  end

  def resolve_create_publication(args, %{context: %{user: user}}) do
    with {:ok, publication} <- Publications.create_publication(args),
         {:ok, publication_membership} <- Publications.create_publication_membership(
           %{role: :owner, member_id: user.id, publication_id: publication.id}) do
      {:ok, %{publication: publication}}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end
end
