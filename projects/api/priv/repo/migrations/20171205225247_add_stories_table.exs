defmodule Margaret.Repo.Migrations.AddStoriesTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    Margaret.Stories.Story.StoryPublishStatus.create_type()
    Margaret.Stories.Story.StoryLicense.create_type()

    create table(:stories) do
      add :title, :string, size: 128, null: false
      add :body, :text, null: false
      add :author_id, references(:users, on_delete: :delete_all), null: false
      add :unique_hash, :string, size: 32, null: false

      add :published_at, :naive_datetime
      add :publish_status, :story_publish_status, null: false
      add :publication_scheduled_at, :naive_datetime, default: nil

      add :publication_id, references(:publications, on_delete: :nilify_all)

      add :license, :story_license, null: false, default: "all_rights_reserved"

      timestamps()
    end

    create unique_index(:stories, [:unique_hash])
  end
end
