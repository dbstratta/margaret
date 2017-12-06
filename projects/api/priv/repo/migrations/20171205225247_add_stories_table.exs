defmodule Margaret.Repo.Migrations.AddStoriesTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:stories) do
      add :title, :string, size: 128, null: false
      add :body, :text, null: false
      add :author_id, references(:users), null: false
      add :summary, :string
      add :slug, :string, size: 64, null: false

      timestamps()
    end

    create unique_index(:stories, [:slug])
  end
end
