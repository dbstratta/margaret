defmodule Margaret.Repo.Migrations.AddStoryStarsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:story_stars) do
      add :story_id, references(:stories), null: false
      add :user_id, references(:users), null: false

      timestamps()
    end

    create unique_index(:story_starts, [:story_id, :user_id])
  end
end
