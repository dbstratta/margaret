defmodule Margaret.Repo.Migrations.AddUsersTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:users) do
      add :username, :string, size: 64, null: false
      add :email, :string, size: 254, null: false

      timestamps()
    end

    create unique_index(:users, [:username])
  end
end
