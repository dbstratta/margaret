defmodule Margaret.Repo.Migrations.AddStoryViewsTable do
  use Ecto.Migration

  def change do
    create table(:story_views) do
      add(:story_id, references(:stories, on_delete: :delete_all), null: false)
      add(:viewer_id, references(:users, on_delete: :delete_all))

      timestamps()
    end
  end
end
