defmodule MargaretWeb.Resolvers.PublicationInvitations do
  @moduledoc """
  The Publication Invitation GraphQL resolvers.
  """

  alias MargaretWeb.Helpers
  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.PublicationInvitation

  @doc """
  Resolves the sending of a publication invitation.
  """
  def resolve_send_publication_invitation(args, %{context: %{viewer: viewer}}) do
    %{publication_id: publication_id, invitee_id: invitee_id, role: role} = args

    publication_id
    |> Publications.get_publication()
    |> do_resolve_send_publication_invitation(invitee_id, viewer, role)
  end

  defp do_resolve_send_publication_invitation(nil = _publication, _invitee_id, _inviter, _role),
    do: Helpers.GraphQLErrors.publication_doesnt_exist()

  defp do_resolve_send_publication_invitation(publication, invitee_id, inviter, role) do
    with %User{} = invitee <- Accounts.get_user(invitee_id),
         true <- Publications.can_invite?(publication, inviter, invitee, role),
         false <- Publications.member?(publication, invitee),
         {:ok, %{invitation: invitation}} <-
           Publications.invite_user(publication, inviter, invitee, role) do
      {:ok, %{invitation: invitation}}
    else
      nil ->
        Helpers.GraphQLErrors.user_doesnt_exist()

      false ->
        Helpers.GraphQLErrors.unauthorized()

      true ->
        {:error, "User is already a member of the publication"}

      {:error, _, reason, _} ->
        {:error, reason}
    end
  end

  @doc """
  Resolves the publication of a publication invitation.
  """
  def resolve_publication(%PublicationInvitation{publication_id: publication_id}, _, _) do
    publication = Publications.get_publication(publication_id)

    {:ok, publication}
  end

  @doc """
  Resolves the invitee of a publication invitation.
  """
  def resolve_invitee(%PublicationInvitation{invitee_id: invitee_id}, _, _) do
    invitee = Accounts.get_user(invitee_id)

    {:ok, invitee}
  end

  @doc """
  Resolves the inviter of a publication invitation.
  """
  def resolve_inviter(%PublicationInvitation{inviter_id: inviter_id}, _, _) do
    inviter = Accounts.get_user(inviter_id)

    {:ok, inviter}
  end

  @doc """
  Accepts a publication invitation.
  """
  def resolve_accept_publication_invitation(%{invitation_id: invitation_id}, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    invitation_id
    |> Publications.get_invitation()
    |> do_resolve_accept_publication_invitation(viewer_id)
  end

  defp do_resolve_accept_publication_invitation(
         %PublicationInvitation{invitee_id: invitee_id} = invitation,
         viewer_id
       )
       when invitee_id === viewer_id do
    case Publications.accept_invitation(invitation) do
      {:ok, %{invitation: invitation}} -> {:ok, %{invitation: invitation}}
      {:error, _, _, _} -> Helpers.GraphQLErrors.something_went_wrong()
    end
  end

  defp do_resolve_accept_publication_invitation(nil, _) do
    {:error, "The invitation doesn't exist"}
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
