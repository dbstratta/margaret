defmodule Margaret.Publications do
  @moduledoc """
  The Publications context.
  """

  import Ecto.Query
  alias Margaret.Repo

  alias Margaret.Publications.{Publication, PublicationMembership, PublicationMembershipInvitation}

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
  @spec is_publication_member?(String.t, String.t) :: boolean
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
  @spec is_publication_admin?(String.t, String.t) :: boolean
  def is_publication_admin?(publication_id, member_id) do
    case get_publication_member_role(publication_id, member_id) do
      :admin -> true
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

  def get_publication_membership_by_publication_and_member(publication_id, member_id) do
    Repo.get_by(PublicationMembership, publication_id: publication_id, member_id: member_id)
  end

  @doc """
  Gets a publication membership invitation.
  """
  def get_publication_membership_invitation(id), do: Repo.get(PublicationMembershipInvitation, id)

  @doc """
  Creates a publication membership invitation.
  """
  def create_publication_membership_invitation(attrs) do
    %PublicationMembershipInvitation{}
    |> PublicationMembershipInvitation.changeset()
    |> Repo.insert()
  end
end
