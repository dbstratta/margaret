defmodule Margaret.Repo.Migrations.AddStoryCommentsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:story_comments, primary_key: false) do
      add :story_id, references(:stories), null: false
      add :comment_id, references(:comments), null: false
    end
  end
end
