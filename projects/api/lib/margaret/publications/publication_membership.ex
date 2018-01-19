defmodule Margaret.Publications.PublicationMembership do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__
  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.Publication

  @type t :: %PublicationMembership{}

  @permitted_attrs [
    :role,
    :member_id,
    :publication_id
  ]

  @required_attrs [
    :role,
    :member_id,
    :publication_id
  ]

  @update_permitted_attrs [
    :role
  ]

  defenum(PublicationMembershipRole, :publication_membership_role, [
    :owner,
    :admin,
    :writer,
    :editor
  ])

  schema "publication_memberships" do
    field(:role, PublicationMembershipRole)
    belongs_to(:member, User)
    belongs_to(:publication, Publication)

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %PublicationMembership{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:member_id)
    |> foreign_key_constraint(:publication_id)
    |> unique_constraint(:member_id)
  end

  @doc false
  def update_changeset(%PublicationMembership{} = publication_membership, attrs) do
    publication_membership
    |> cast(attrs, @update_permitted_attrs)
  end
end
