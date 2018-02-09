defmodule Margaret.Repo.Migrations.AddCollectionStoriesTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:collection_stories) do
      add(:story_id, references(:stories, on_delete: :delete_all), null: false)
      add(:collection_id, references(:collections, on_delete: :delete_all), null: false)

      add(:part, :integer)

      timestamps()
    end

    create(unique_index(:collection_stories, [:story_id]))
    create(index(:collection_stories, [:collection_id]))
  end
end
