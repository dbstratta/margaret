defmodule MargaretWeb.Resolvers.PublicationInvitations do
  @moduledoc """
  The Publication Invitation GraphQL resolvers.
  """

  alias MargaretWeb.Helpers
  alias Margaret.{Accounts, Publications}
  alias Publications.PublicationInvitation

  # TODO: Refactor this resolver into function calls from context.
  def resolve_send_publication_invitation(args, %{context: %{viewer: inviter}}) do
    # %{publication_id: publication_id, invitee_id: invitee_id, role: role} = args

    # publication_id
    # |> Publications.get_publication()
    # |> do_resolve_send_publication_invitation(inviter, invitee_id, role)

    # # ----------
    # if(Publications.can_invite?())

    # attrs = %{
    #   publication_id: publication_id,
    #   invitee_id: invitee_id,
    #   inviter_id: viewer_id,
    #   role: role,
    #   status: :pending
    # }

    # with true <- Publications.admin?(publication_id, viewer_id),
    #      false <- Publications.publication_member?(publication_id, invitee_id),
    #      {:ok, invitation} <- Publications.insert_publication_invitation(attrs) do
    #   {:ok, %{invitation: invitation}}
    # else
    #   false -> Helpers.GraphQLErrors.unauthorized()
    #   true -> {:error, "Invitee is already a member of the publication."}
    #   {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    # end
  end

  # defp do_resolve_send_publication_invitation(
  #        %Publication{} = publication,
  #        inviter,
  #        invitee_id,
  #        role
  #      ) do
  # end

  def resolve_publication(%PublicationInvitation{publication_id: publication_id}, _, _) do
    {:ok, Publications.get_publication(publication_id)}
  end

  def resolve_invitee(%PublicationInvitation{invitee_id: invitee_id}, _, _) do
    {:ok, Accounts.get_user(invitee_id)}
  end

  def resolve_inviter(%PublicationInvitation{inviter_id: inviter_id}, _, _) do
    {:ok, Accounts.get_user(inviter_id)}
  end

  @doc """
  Accepts a publication invitation.
  """
  def resolve_accept_publication_invitation(%{invitation_id: invitation_id}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    invitation_id
    |> Publications.get_publication_invitation()
    |> do_resolve_accept_publication_invitation(viewer_id)
  end

  defp do_resolve_accept_publication_invitation(
         %PublicationInvitation{invitee_id: invitee_id} = invitation,
         viewer_id
       )
       when invitee_id === viewer_id do
    case Publications.accept_publication_invitation(invitation) do
      {:ok, %{invitation: invitation}} -> {:ok, %{invitation: invitation}}
      {:error, _, _, _} -> Helpers.GraphQLErrors.something_went_wrong()
    end
  end

  defp do_resolve_accept_publication_invitation(nil, _) do
    {:error, "The invitation doesn't exist."}
  end

  defp do_resolve_accept_publication_invitation(
         %PublicationInvitation{invitee_id: invitee_id},
         viewer_id
       )
       when invitee_id !== viewer_id do
    Helpers.GraphQLErrors.unauthorized()
  end

  @doc """
  Rejects a publication invitation.
  """
  def resolve_reject_publication_invitation(%{invitation_id: invitation_id}, %{
        context: %{viewer: viewer}
      }) do
    with %PublicationInvitation{} = invitation <- Publications.get_invitation(invitation_id),
         true <- Publications.can_reject_invitation?(invitation, viewer),
         invitation <- Publications.reject_invitation!(invitation) do
      {:ok, %{invitation: invitation}}
    else
      nil -> Helpers.GraphQLErrors.invitation_doesnt_exist()
      false -> Helpers.GraphQLErrors.unauthorized()
    end
  end
end
