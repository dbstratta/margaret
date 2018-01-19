defmodule Margaret.Repo.Migrations.AddStoryTagsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:story_tags, primary_key: false) do
      add(:story_id, references(:stories, on_delete: :delete_all), null: false)
      add(:tag_id, references(:tags, on_delete: :delete_all), null: false)
    end

    create(unique_index(:story_tags, [:story_id, :tag_id]))
  end
end
