defmodule Margaret.Repo.Migrations.AddStoriesTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    Margaret.Stories.Story.StoryAudience.create_type()
    Margaret.Stories.Story.StoryLicense.create_type()

    create table(:stories) do
      add(:content, :map, null: false)
      add(:author_id, references(:users, on_delete: :delete_all), null: false)
      add(:unique_hash, :string, size: 32, null: false)

      add(:audience, :story_audience, null: false)
      add(:published_at, :naive_datetime)

      add(:publication_id, references(:publications, on_delete: :nilify_all))

      add(:license, :story_license, null: false, default: "all_rights_reserved")

      timestamps()
    end

    create(unique_index(:stories, [:unique_hash]))
    create(index(:stories, [:author_id]))

    create(
      index(
        :stories,
        [:publication_id],
        where: "publication_id is not null",
        name: :publication_stories
      )
    )
  end
end
