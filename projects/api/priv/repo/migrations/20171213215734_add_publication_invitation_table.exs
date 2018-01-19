defmodule Margaret.Repo.Migrations.AddPublicationInvitationTable do
  use Ecto.Migration

  def change do
    Margaret.Publications.PublicationInvitation.PublicationInvitationStatus.create_type()
    Margaret.Publications.PublicationInvitation.PublicationInvitationRole.create_type()

    create table(:publication_invitations) do
      add(:inviter_id, references(:users, on_delete: :delete_all), null: false)
      add(:invitee_id, references(:users, on_delete: :nilify_all), null: false)
      add(:publication_id, references(:publications, on_delete: :delete_all), null: false)
      add(:role, :publication_invitation_role, null: false)
      add(:status, :publication_invitation_status, null: false)

      timestamps()
    end
  end
end
