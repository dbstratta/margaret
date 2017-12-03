defmodule Margaret.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, size: 64, null: false
      add :email, :string, size: 254, null: false

      timestamps()
    end
  end
end
