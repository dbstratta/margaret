defmodule Margaret.Repo.Migrations.AddPublicationsTable do
  use Ecto.Migration

  def change do
    create table(:publications) do
      add :name, :string, size: 64, null: false

      timestamps()
    end
  end
end
