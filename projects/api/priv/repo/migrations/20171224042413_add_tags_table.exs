defmodule Margaret.Repo.Migrations.AddTagsTable do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:title, :string, size: 64, null: false)

      timestamps()
    end

    create(unique_index(:tags, [:title]))
  end
end
