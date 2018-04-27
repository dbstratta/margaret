defmodule Margaret.Repo.Migrations.AddStoryViewsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:story_views) do
      add(:story_id, references(:stories, on_delete: :delete_all), null: false)
      add(:viewer_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(index(:story_views, [:story_id]))
    create(index(:story_views, [:viewer_id]))
  end
end
