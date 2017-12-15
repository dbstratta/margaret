defmodule MargaretWeb.Resolvers.Publications do
  @moduledoc """
  The Publication GraphQL resolvers.
  """

  alias MargaretWeb.Helpers
  alias Margaret.Publications

  def resolve_publication(%{name: name}, _) do
    {:ok, Publications.get_publication_by_name(name)}
  end

  def resolve_members(_, _, _) do

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
      {:ok, publication}
    else
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def resolve_send_publication_membership_invitation(args, _) do
    %{publication_id: %{id: publication_id}, invitee: invitee} = args

  end

  def resolve_accept_publication_membership_invitation(_, _) do

  end

  def resolve_reject_publication_membership_invitation(_, _) do

  end
end
