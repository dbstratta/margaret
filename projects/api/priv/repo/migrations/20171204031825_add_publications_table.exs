defmodule Margaret.Repo.Migrations.AddPublicationsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:publications) do
      add(:name, :string, size: 64, null: false)
      add(:display_name, :string, null: false)

      timestamps()
    end

    create(unique_index(:publications, [:name]))
  end
end
