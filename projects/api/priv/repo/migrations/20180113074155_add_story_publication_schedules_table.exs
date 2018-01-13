defmodule Margaret.Repo.Migrations.AddStoryPublicationSchedulesTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:story_publication_schedules) do
      add :story_id, references(:stories, on_delete: :delete_all), null: false, primary_key: true
      add :publish_at, :naive_datetime, null: false
    end
  end
end
