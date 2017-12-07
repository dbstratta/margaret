defmodule Margaret.Repo.Migrations.AddStoryStarsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:story_stars, primary_key: false) do
      add :story_id, references(:stories), null: false
      add :star_id, references(:stars), null: false
    end

    create unique_index(:story_stars, [:story_id, :star_id])
  end
end
