defmodule Margaret.Repo.Migrations.AddStoryStarsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:story_stars) do
      add :story_id, references(:stories), null: false
      add :star_id, references(:stars), null: false

      timestamps()
    end
  end
end
