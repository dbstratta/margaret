defmodule Margaret.Repo.Migrations.AddStoriesTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:stories) do
      add :title, :string, size: 128, null: false
      add :body, :text, null: false
      add :author_id, references(:users), null: false
      add :summary, :string, size: 256
      add :slug, :string, null: false
      add :publication_id, references(:publications)
      add :published_at, :naive_datetime, default: nil

      timestamps()
    end

    create unique_index(:stories, [:slug])
  end
end
