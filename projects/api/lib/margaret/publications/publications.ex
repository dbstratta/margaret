defmodule Margaret.Publications do
  @moduledoc """
  The Publications context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Publications,
    Follows,
    Tags
  }

  alias Stories.Story
  alias Publications.{Publication, PublicationMembership, PublicationInvitation}
  alias Accounts.User

  @typedoc """
  The role of a member in a publication.
  """
  @type role :: atom

  @doc """
  Gets a publication by its id.

  ## Examples

      iex> get_publication(123)
      %Publication{}

      iex> get_publication(456)
      nil

  """
  @spec get_publication(String.t() | non_neg_integer) :: Publication.t() | nil
  def get_publication(id), do: Repo.get(Publication, id)

  @doc """
  Gets a publication by its name.

  ## Examples

      iex> get_publication_by_name("publication123")
      %Publication{}

      iex> get_publication_by_name("publication456")
      nil

  """
  @spec get_publication_by_name(String.t()) :: Publication.t() | nil
  def get_publication_by_name(name), do: get_publication_by(name: name)

  @doc """
  Gets a publication by given clauses.
  """
  @spec get_publication_by(Keyword.t()) :: Publication.t() | nil
  def get_publication_by(clauses), do: Repo.get_by(Publication, clauses)

  @doc """
  """
  @spec get_tags(Publication.t()) :: [Tag.t()]
  def get_tags(%Publication{} = publication) do
    publication
    |> Publication.preload_tags()
    |> Map.get(:tags)
  end

  @doc """
  Gets the role of a member of a publication.
  Returns `nil` if the user is not a member.

  ## Examples

      iex> get_member_role(%Publication{}, %User{})
      :owner

      iex> get_member_role(%Publication{}, %User{})
      nil

  """
  @spec get_member_role(Publication.t(), User.t()) :: role | nil
  def get_member_role(%Publication{id: publication_id}, %User{id: user_id}) do
    case get_membership(publication_id: publication_id, member_id: user_id) do
      %PublicationMembership{role: role} -> role
      nil -> nil
    end
  end

  @doc """
  Returns the member count of the publication.

  ## Examples

    iex> get_member_count(%Publication{})
    3

  """
  @spec get_member_count(Publication.t()) :: non_neg_integer
  def get_member_count(%Publication{} = publication) do
    query = PublicationMembership.by_publication(publication)

    Repo.aggregate(query, :count, :id)
  end

  @doc """
  Returns the story count of the publication.
  """
  @spec get_story_count(Publication.t(), Keyword.t()) :: non_neg_integer
  def get_story_count(%Publication{} = publication, opts \\ []) do
    query = Story.under_publication(publication)

    query =
      if Keyword.get(opts, :published_only, false) do
        Story.published(query)
      else
        query
      end

    Repo.aggregate(query, :count, :id)
  end

  @doc """
  Gets the follower count of a publication.
  """
  @spec get_follower_count(Publication.t()) :: non_neg_integer
  def get_follower_count(%Publication{} = publication),
    do: Follows.get_follower_count(publication: publication)

  @doc """
  Checks that the user's role in the publication
  is in the list of permitted roles.

  ## Examples

    iex> check_role(%Publication{}, %User{}, [:admin, :editor])
    true

    iex> check_role(%Publication{}, %User{}, :writer)
    false

  """
  @spec check_role(Publication.t(), User.t(), [role, ...] | role) :: boolean
  def check_role(publication, user, permitted_roles) when is_list(permitted_roles) do
    get_member_role(publication, user) in permitted_roles
  end

  def check_role(publication, user, role), do: get_member_role(publication, user) === role

  @doc """
  Returns true if the user is a member
  of the publication. False otherwise.

  ## Examples

      iex> member?(%Publication{}, %User{})
      true

      iex> member?(%Publication{}, %User{})
      false

  """
  @spec member?(Publication.t(), User.t()) :: boolean
  def member?(publication, user), do: !!get_member_role(publication, user)

  @doc """
  Returns true if the user is a editor
  of the publication. False otherwise.

  ## Examples

      iex> editor?(%Publication{}, %User{})
      true

      iex> editor?(%Publication{}, %User{})
      false

  """
  @spec editor?(Publication.t(), User.t()) :: boolean
  def editor?(publication, user), do: check_role(publication, user, :editor)

  @doc """
  Returns true if the user is a writer
  of the publication. False otherwise.

  ## Examples

      iex> writer?(%Publication{}, %User{})
      true

      iex> writer?(%Publication{}, %User{})
      false

  """
  @spec writer?(Publication.t(), User.t()) :: boolean
  def writer?(publication, user), do: check_role(publication, user, :writer)

  @doc """
  Returns true if the user is an admin
  of the publication. False otherwise.

  ## Examples

      iex> admin?(%Publication{}, %User{})
      true

      iex> admin?(%Publication{}, %User{})
      false

  """
  @spec admin?(Publication.t(), User.t()) :: boolean
  def admin?(publication, user), do: check_role(publication, user, :admin)

  @doc """
  Returns true if the user is the owner
  of the publication. False otherwise.

  ## Examples

      iex> owner?(%Publication{}, %User{})
      true

      iex> owner?(%Publication{}, %User{})
      false

  """
  @spec owner?(Publication.t(), User.t()) :: boolean
  def owner?(publication, user), do: check_role(publication, user, :owner)

  @doc """
  Returns true if the user can write stories for the publication.
  False otherwise.

  ## Examples

      iex> can_write_stories?(%Publication{}, %User{})
      true

      iex> can_write_stories?(%Publication{}, %User{})
      false

  """
  @spec can_write_stories?(Publication.t(), User.t()) :: boolean
  def can_write_stories?(publication, user) do
    roles = ~w(owner admin editor writer)a

    check_role(publication, user, roles)
  end

  @doc """
  Returns true if the user can publish stories for the publication.
  False otherwise.

  ## Examples

      iex> can_publish_stories?(%Publication{}, %User{})
      true

      iex> can_publish_stories?(%Publication{}, %User{})
      false

  """
  @spec can_publish_stories?(Publication.t(), User.t()) :: boolean
  def can_publish_stories?(publication, user) do
    roles = ~w(owner admin editor)a

    check_role(publication, user, roles)
  end

  @doc """
  Returns true if the user can edit stories for the publication.
  False otherwise.

  ## Examples

      iex> can_edit_stories?(%Publication{}, %User{})
      true

      iex> can_edit_stories?(%Publication{}, %User{})
      false

  """
  @spec can_edit_stories?(Publication.t(), User.t()) :: boolean
  def can_edit_stories?(publication, user) do
    roles = ~w(owner admin editor)a

    check_role(publication, user, roles)
  end

  @doc """
  Returns true if the user can see the invitations sent by the publication.
  False otherwise.

  ## Examples

      iex> can_see_invitations?(%Publication{}, %User{})
      true

      iex> can_see_invitations?(%Publication{}, %User{})
      false

  """
  @spec can_see_invitations?(Publication.t(), User.t()) :: boolean
  def can_see_invitations?(publication, user) do
    roles = ~w(owner admin)a

    check_role(publication, user, roles)
  end

  @doc """
  Returns true if the user can invite a
  user with a role to the publication.
  False otherwise.

  ## Examples

      iex> can_invite?(publication, inviter, invitee, :writer)
      true

      iex> can_invite?(publication, inviter, invitee, :owner)
      false

  """
  @spec can_invite?(Publication.t(), User.t(), User.t(), role) :: boolean
  def can_invite?(publication, inviter, invitee, role) when role in [:writer, :editor] do
    roles = ~w(owner admin)a

    publication
    |> check_role(inviter, roles)
    |> do_can_invite?(publication, invitee)
  end

  def can_invite?(publication, inviter, invitee, role) when role === :admin do
    publication
    |> check_role(inviter, :owner)
    |> do_can_invite?(publication, invitee)
  end

  def can_invite?(_publication, _inviter, _invitee, _role), do: false

  defp do_can_invite?(true, publication, invitee), do: not member?(publication, invitee)

  defp do_can_invite?(false, _publication, _invitee), do: false

  @doc """
  Returns true if the user can update the publication information.
  False otherwise.

  ## Examples

      iex> can_update_publication?(%Publication{}, %User{})
      true

      iex> can_update_publication?(%Publication{}, %User{})
      false

  """
  @spec can_update_publication?(Publication.t(), User.t()) :: boolean
  def can_update_publication?(publication, user) do
    roles = ~w(owner admin)a

    check_role(publication, user, roles)
  end

  @doc """
  """
  @spec can_kick?(Publication.t(), User.t(), User.t()) :: boolean
  def can_kick?(publication, kicker, user) do
    case get_member_role(publication, user) do
      nil -> false
      :owner -> false
      :admin -> check_role(publication, kicker, ~w(owner)a)
      _role -> check_role(publication, kicker, ~w(owner admin)a)
    end
  end

  @doc """
  Returns `true` if the user can accept the invitation.
  `false` otherwise.
  """
  @spec can_accept_invitation?(PublicationInvitation.t(), User.t()) :: boolean
  def can_accept_invitation?(%PublicationInvitation{invitee_id: invitee_id}, %User{id: invitee_id}),
      do: true

  def can_accept_invitation?(_invitation, _user), do: false

  @doc """
  Returns `true` if the user can reject the invitation.
  `false` otherwise.
  """
  @spec can_reject_invitation?(PublicationInvitation.t(), User.t()) :: boolean
  def can_reject_invitation?(%PublicationInvitation{invitee_id: invitee_id}, %User{id: invitee_id}),
      do: true

  def can_reject_invitation?(_invitation, _user), do: false

  @doc """
  Inserts a publication.
  """
  def insert_publication(attrs) do
    Multi.new()
    |> maybe_insert_tags(attrs)
    |> insert_publication(attrs)
    |> insert_owner(attrs)
    |> Repo.transaction()
  end

  defp insert_publication(multi, attrs) do
    insert_publication_fn = fn changes ->
      maybe_put_tags = fn attrs ->
        case changes do
          %{tags: tags} -> Map.put(attrs, :tags, tags)
          _ -> attrs
        end
      end

      attrs
      |> maybe_put_tags.()
      |> Publication.changeset()
      |> Repo.insert()
    end

    Multi.run(multi, :publication, insert_publication_fn)
  end

  @doc """
  Updates a publication.
  """
  def update_publication(%Publication{} = publication, attrs) do
    Multi.new()
    |> maybe_insert_tags(attrs)
    |> update_publication(publication, attrs)
    |> Repo.transaction()
  end

  defp update_publication(multi, %Publication{} = publication, attrs) do
    update_publication_fn = fn changes ->
      maybe_put_tags = fn {publication, attrs} ->
        case changes do
          %{tags: tags} -> {Publication.preload_tags(publication), Map.put(attrs, :tags, tags)}
          _ -> {publication, attrs}
        end
      end

      {publication, attrs} = maybe_put_tags.({publication, attrs})

      publication
      |> Publication.update_changeset(attrs)
      |> Repo.update()
    end

    Multi.run(multi, :publication, update_publication_fn)
  end

  defp maybe_insert_tags(multi, %{tags: tags}) do
    insert_tags_fn = fn _ -> {:ok, Tags.insert_and_get_all_tags(tags)} end

    Multi.run(multi, :tags, insert_tags_fn)
  end

  defp maybe_insert_tags(multi, _attrs), do: multi

  defp insert_owner(multi, %{owner_id: owner_id}) do
    insert_owner_fn = fn %{publication: %{id: publication_id}} ->
      insert_membership(%{
        role: :owner,
        member_id: owner_id,
        publication_id: publication_id
      })
    end

    Multi.run(multi, :owner, insert_owner_fn)
  end

  @doc """
  Inserts a publication.
  """
  @spec insert_publication!(any) :: Publication.t() | no_return
  def insert_publication!(attrs) do
    case insert_publication(attrs) do
      {:ok, %{publication: publication}} ->
        publication

      {:error, _, reason, _} ->
        raise """
        cannot insert publication.
        Reason: #{inspect(reason)}
        """
    end
  end

  @doc """
  Inserts a publication membership.
  """
  def insert_membership(attrs) do
    attrs
    |> PublicationMembership.changeset()
    |> Repo.insert()
  end

  @doc """
  Gets a publication membership.
  """
  def get_membership(id) when not is_list(id), do: Repo.get(PublicationMembership, id)

  def get_membership(clauses) when length(clauses) == 2,
    do: Repo.get_by(PublicationMembership, clauses)

  @doc """
  Gets the owner of the publication.
  """
  @spec get_owner(Publication.t()) :: User.t()
  def get_owner(%Publication{} = publication) do
    query =
      User
      |> join(:inner, [u], pm in assoc(u, :publication_memberships))
      |> PublicationMembership.by_publication(publication)
      |> PublicationMembership.owner()

    Repo.one!(query)
  end

  @doc """
  Deletes a publication membership.
  """
  def delete_membership(%PublicationMembership{} = publication_membership),
    do: Repo.delete(publication_membership)

  @doc """
  Gets a publication invitation.
  """
  def get_invitation(id), do: Repo.get(PublicationInvitation, id)

  @doc """
  Inserts a publication invitation.
  """
  def insert_invitation(attrs) do
    attrs
    |> PublicationInvitation.changeset()
    |> Repo.insert()
  end

  @doc """
  Updates a publication invitation.
  """
  @spec update_invitation(PublicationInvitation.t(), any) ::
          {:ok, PublicationInvitation.t()} | {:error, Ecto.Changeset.t()}
  def update_invitation(%PublicationInvitation{} = invitation, attrs) do
    invitation
    |> PublicationInvitation.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a publication invitation.
  """
  @spec update_invitation!(PublicationInvitation.t(), any) ::
          PublicationInvitation.t() | no_return
  def update_invitation!(%PublicationInvitation{} = invitation, attrs) do
    case update_invitation(invitation, attrs) do
      {:ok, invitation} ->
        invitation

      {:error, reason} ->
        raise """
        cannot update invitation.
        Reason: #{inspect(reason)}
        """
    end
  end

  @doc """
  Accepts a publication invitation.
  Rejects all other invitations to the invitee.
  """
  def accept_invitation(%PublicationInvitation{} = invitation) do
    invitation_changeset =
      PublicationInvitation.update_changeset(invitation, %{status: :accepted})

    reject_others_invitations =
      from(
        i in PublicationInvitation,
        where: i.invitee_id == ^invitation.invitee_id and i.id != ^invitation.id,
        where: i.status == ^:pending,
        update: [set: [status: ^:rejected]]
      )

    membership_attrs = %{
      role: invitation.role,
      publication_id: invitation.publication_id,
      member_id: invitation.invitee_id
    }

    membership_changeset = PublicationMembership.changeset(membership_attrs)

    Multi.new()
    |> Multi.update(:invitation, invitation_changeset)
    |> Multi.update_all(:reject_other_invitations, reject_others_invitations, [])
    |> Multi.insert(:membership, membership_changeset)
    |> Repo.transaction()
  end

  @doc """
  Rejects a publcation invitation.
  """
  def reject_invitation(invitation), do: update_invitation(invitation, %{status: :rejected})

  @doc """
  Rejects a publcation invitation.
  """
  @spec reject_invitation(PublicationInvitation.t()) :: PublicationInvitation.t() | no_return
  def reject_invitation!(invitation) do
    case reject_invitation(invitation) do
      {:ok, invitation} ->
        invitation

      {:error, reason} ->
        raise """
        cannot reject invitation.
        Reason: #{inspect(reason)}
        """
    end
  end

  @doc """
  Invites a user to a publication.
  """
  @spec invite_user(Publication.t(), User.t(), User.t(), role) :: {atom, any}
  def invite_user(publication, inviter, invitee, role) do
    attrs = %{
      publication_id: publication.id,
      inviter_id: inviter.id,
      invitee_id: invitee.id,
      role: role,
      status: :pending
    }

    insert_invitation(attrs)
  end

  @doc """
  Kicks a member out of a publication.
  """
  def kick_member(%Publication{id: publication_id}, %User{id: user_id}) do
    [publication_id: publication_id, member_id: user_id]
    |> get_membership()
    |> case do
      %PublicationMembership{} = membership -> delete_membership(membership)
      nil -> {:error, "User is not a member of the publication"}
    end
  end

  @doc """
  Kicks a member out of a publication.
  """
  def kick_member!(publication, user) do
    case kick_member(publication, user) do
      {:ok, membership} ->
        membership

      {:error, reason} ->
        raise """
        cannot kick member from the publication.
        Reason: #{inspect(reason)}
        """
    end
  end
end
