defmodule Margaret.Repo.Migrations.AddPublicationMembershipsTable do
  use Ecto.Migration

  def change do
    Margaret.Publications.PublicationMembership.PublicationMembershipRole.create_type()

    create table(:publication_memberships) do
      add(:role, :publication_membership_role, null: false)
      add(:member_id, references(:users, on_delete: :delete_all), null: false)
      add(:publication_id, references(:publications, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:publication_memberships, [:member_id, :publication_id]))
  end
end
