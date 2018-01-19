defmodule Margaret.Repo.Migrations.AddUsersTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:users) do
      add(:username, :string, size: 64, null: false)
      add(:email, :string, size: 254, null: false)

      add(:is_employee, :boolean, default: false, null: false)
      add(:is_admin, :boolean, default: false, null: false)

      add(:deactivated_at, :naive_datetime, default: nil)

      timestamps()
    end

    create(unique_index(:users, [:username]))
    create(unique_index(:users, [:email]))
  end
end
