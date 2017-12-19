defmodule MargaretWeb.Resolvers.PublicationInvitations do
  @moduledoc """
  The Publication Invitation GraphQL resolvers.
  """

  alias MargaretWeb.Helpers
  alias Margaret.{Accounts, Publications}
  alias Publications.PublicationInvitation

  def resolve_send_publication_invitation(_, %{context: %{user: nil}}) do
    Helpers.GraphQLErrors.unauthorized()
  end

  def resolve_send_publication_invitation(args, %{context: %{user: %{id: user_id}}}) do
    %{publication_id: publication_id, invitee_id: invitee_id, role: role} = args
    attrs = %{
      publication_id: publication_id,
      invitee_id: invitee_id,
      inviter_id: user_id,
      role: role,
      status: :pending
    }

    with true <- Publications.is_publication_admin?(publication_id, user_id),
         false <- Publications.is_publication_member?(publication_id, invitee_id),
         {:ok, invitation} <- Publications.create_publication_invitation(attrs) do
      {:ok, %{invitation: invitation}}
    else
      false -> Helpers.GraphQLErrors.unauthorized()
      true -> {:error, "Invitee is already a member of the publication."}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def resolve_publication(%PublicationInvitation{publication_id: publication_id}, _, _) do
    {:ok, Publications.get_publication(publication_id)}
  end

  def resolve_invitee(%PublicationInvitation{invitee_id: invitee_id}, _, _) do
    {:ok, Accounts.get_user(invitee_id)}
  end

  def resolve_inviter(%PublicationInvitation{inviter_id: inviter_id}, _, _) do
    {:ok, Accounts.get_user(inviter_id)}
  end

  def resolve_accept_publication_invitation(_, %{context: %{user: nil}}) do
    Helpers.GraphQLErrors.unauthorized()
  end

  def resolve_accept_publication_invitation(args, %{context: %{user: %{id: user_id}}}) do
    %{invitation_id: invitation_id} = args
    invitation = Publications.get_publication_invitation(invitation_id)
    membership_attrs = %{
      member_id: invitation.invitee_id,
      publication_id: invitation.publication_id,
      role: invitation.role,
    }

    with %PublicationInvitation{} <- invitation,
         true <- invitation.invitee_id === user_id,
         {:ok, invitation} <- Publications.accept_publication_invitation(invitation),
         {:ok, membership} <- Publications.create_publication_membership(membership_attrs) do
      {:ok, %{invitation: invitation}}
    else
      nil -> Helpers.GraphQLErrors.something_went_wrong()
      false -> Helpers.GraphQLErrors.unauthorized()
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def resolve_reject_publication_invitation(_, _) do

  end
end
