defmodule Margaret.Publications.PublicationMembership do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__, as: PublicationMembership
  alias Margaret.{Accounts, Publications}
  alias Accounts.User
  alias Publications.Publication

  @typedoc "The Publication type"
  @type t :: %Publication{}

  defenum PublicationMembershipRole,
    :publication_membership_role,
    [:owner, :admin, :writer]

  schema "publication_memberships" do
    field :role, PublicationMembershipRole
    belongs_to :member, User
    belongs_to :publication, Publication

    timestamps()
  end

  @doc false
  def changeset(%PublicationMembership{} = publication_membership, attrs) do
    publication_membership
    |> cast(attrs, [:role, :member_id, :publication_id])
    |> validate_required([:role, :member_id, :publication_id])
    |> foreign_key_constraint(:member_id)
    |> foreign_key_constraint(:publication_id)
    |> unique_constraint(:member_id)
  end
end
