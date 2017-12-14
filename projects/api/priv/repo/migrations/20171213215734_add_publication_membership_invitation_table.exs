defmodule Margaret.Repo.Migrations.AddPublicationMembershipInvitationTable do
  use Ecto.Migration

  def change do
    create table(:publication_membership_invitations) do
      add :inviter_id, references(:users, on_delete: :delete_all), null: false
      add :invitee_id, references(:users, on_delete: :nilify_all), null: false
      add :publication_id, references(:publications, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
