defmodule Margaret.Repo.Migrations.AddStoriesTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:stories) do
      add :title, :string, size: 128, null: false
      add :body, :text, null: false
      add :author_id, references(:users, on_delete: :delete_all), null: false
      add :summary, :string, size: 256
      add :unique_hash, :string, size: 32, null: false
      add :publication_id, references(:publications, on_delete: :nilify_all)
      add :published_at, :naive_datetime, default: nil

      timestamps()
    end

    create unique_index(:stories, [:unique_hash])
  end
end
