defmodule Margaret.Publications do
  @moduledoc """
  The Publications context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{Repo, Accounts, Publications}
  alias Publications.{Publication, PublicationMembership, PublicationInvitation}
  alias Accounts.User

  @doc """
  Gets a publication by its id.

  ## Examples

      iex> get_publication(123)
      %Publication{}

      iex> get_publication(456)
      nil

  """
  def get_publication(id), do: Repo.get(Publication, id)

  @doc """
  Gets a publication by its name.

  ## Examples

      iex> get_publication_by_name("publication123")
      %Publication{}

      iex> get_publication_by_name("publication456")
      nil

  """
  def get_publication_by_name(name), do: Repo.get_by(Publication, name: name)

  @doc """
  Gets the role of a member of a publication.
  Returns `nil` if the user is not a member.

  ## Examples

      iex> get_publication_member_role(123, 123)
      :owner

      iex> get_publication_member_role(123, 456)
      nil

  """
  @spec get_publication_member_role(term, term) :: atom | nil
  def get_publication_member_role(publication_id, member_id) do
    case get_publication_membership_by_publication_and_member(publication_id, member_id) do
      %PublicationMembership{role: role} -> role
      nil -> nil
    end
  end

  @doc """
  Returns true if the user is a member
  of the publication. False otherwise.

  ## Examples

      iex> is_publication_member?(123, 123)
      true

      iex> is_publication_member?(123, 456)
      false

  """
  @spec is_publication_member?(term, term) :: boolean
  def is_publication_member?(publication_id, member_id) do
    case get_publication_member_role(publication_id, member_id) do
      role when is_atom(role) -> true
      _ -> false
    end
  end

  @doc """
  Returns true if the user is an admin
  of the publication. False otherwise.

  ## Examples

      iex> is_publication_admin?(123, 123)
      true

      iex> is_publication_admin?(123, 456)
      false

  """
  @spec is_publication_admin?(term, term) :: boolean
  def is_publication_admin?(publication_id, member_id) do
    case get_publication_member_role(publication_id, member_id) do
      role when role in [:owner, :admin] -> true
      _ -> false
    end
  end

  @doc """
  Returns true if the user can write stories for the publication.
  False otherwise.

  ## Examples

      iex> can_write_stories?(123, 123)
      true

      iex> can_write_stories?(123, 456)
      false

  """
  @spec can_write_stories?(term, term) :: boolean
  def can_write_stories?(publication_id, member_id) do
    case get_publication_member_role(publication_id, member_id) do
      role when role in [:owner, :writer] -> true
      _ -> false
    end
  end

  @doc """
  Creates a publication.
  """
  def create_publication(attrs) do
    %Publication{}
    |> Publication.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a publication membership.
  """
  def create_publication_membership(attrs) do
    %PublicationMembership{}
    |> PublicationMembership.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a publication membership.
  """
  def get_publication_membership(id), do: Repo.get(PublicationMembership, id)

  def get_publication_owner(publication_id) do
    query = from u in User,
      join: pm in PublicationMembership, on: pm.member_id == u.id,
      where: pm.publication_id == ^publication_id and pm.role == ^:owner,
      select: u

    Repo.one!(query)
  end

  @doc """
  Gets a publication membership by publication and member ids.
  """
  def get_publication_membership_by_publication_and_member(publication_id, member_id) do
    Repo.get_by(PublicationMembership, publication_id: publication_id, member_id: member_id)
  end

  @doc """
  Gets a publication invitation.
  """
  def get_publication_invitation(id), do: Repo.get(PublicationInvitation, id)

  @doc """
  Creates a publication invitation.
  """
  def create_publication_invitation(attrs) do
    %PublicationInvitation{}
    |> PublicationInvitation.changeset(attrs)
    |> Repo.insert()
  end

  def update_publication_invitation(%PublicationInvitation{} = invitation, attrs) do
    invitation
    |> PublicationInvitation.changeset(attrs)
    |> Repo.update()
  end

  def accept_publication_invitation(%PublicationInvitation{} = invitation) do
    invitation_changeset = PublicationInvitation.changeset(invitation, %{status: :accepted})
    update_others_invitations = from i in PublicationInvitation,
      where: i.invitee_id == ^invitation.invitee_id and i.id != ^invitation.id,
      update: [set: [status: ^:rejected]]
    
    membership_attrs = %{
      role: invitation.role,
      publication_id: invitation.publication_id,
      member_id: invitation.invitee_id,
    }
    membership_changeset = PublicationMembership.changeset(
      %PublicationMembership{}, membership_attrs)


    Multi.new
    |> Multi.update(:invitation, PublicationInvitation.changeset(invitation_changeset))
    |> Multi.update_all(:other_invitations, update_others_invitations, [])
    |> Multi.insert(:membership, membership_changeset)
    |> Repo.transaction()
  end

  def reject_publication_invitation(%PublicationInvitation{} = invitation) do
    update_publication_invitation(invitation, %{status: :rejected})
  end
end
