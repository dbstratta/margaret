defmodule Margaret.Repo.Migrations.AddStoryCommentsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:story_comments) do
      add :story_id, references(:stories), null: false
      add :comment_id, references(:comments), null: false

      timestamps()
    end
  end
end
