defmodule Margaret.Repo.Migrations.AddStoryTagsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:story_tags, primary_key: false) do
      add(:story_id, references(:stories, on_delete: :delete_all), null: false, primary_key: true)
      add(:tag_id, references(:tags, on_delete: :delete_all), null: false, primary_key: true)
    end
  end
end
