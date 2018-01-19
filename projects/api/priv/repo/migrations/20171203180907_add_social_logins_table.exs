defmodule Margaret.Repo.Migrations.AddSocialLoginsTable do
  use Ecto.Migration

  def change do
    create table(:social_logins) do
      add(:uid, :string, null: false)
      add(:provider, :string, size: 32, null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(unique_index(:social_logins, [:uid, :provider]))
  end
end
