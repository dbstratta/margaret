defmodule MargaretWeb.Resolvers.PublicationMembershipInvitations do
  @moduledoc """
  The Publication Membership Invitation GraphQL resolvers.
  """

  alias MargaretWeb.Helpers
  alias Margaret.Publications

  def resolve_send_publication_membership_invitation(_, %{context: %{user: nil}}) do
    Helpers.GraphQLErrors.unauthorized()
  end

  def resolve_send_publication_membership_invitation(args, %{context: %{user: user}}) do
    %{publication_id: %{id: publication_id}, invitee_id: %{id: invitee_id}} = args
    attrs = %{publication_id: publication_id, invitee_id: invitee_id, inviter_id: user.id}

    with true <- Publications.is_publication_admin?(publication_id, user.id),
         {:ok, invitation} <- Publications.create_publication_membership_invitation(attrs) do
      {:ok, %{invitation: invitation}}
    else
      false -> Helpers.GraphQLErrors.unauthorized()
      {:error, %Ecto.Changeset{} = changeset} -> {:error, changeset}
    end
  end

  def resolve_accept_publication_membership_invitation(_, _) do

  end

  def resolve_reject_publication_membership_invitation(_, _) do

  end
end
