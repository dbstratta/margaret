defmodule Margaret.Repo.Migrations.AddCommentsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:comments) do
      add :body, :text, null: false
      add :author_id, references(:users), null: false

      add :story_id, references(:stories)

      timestamps()
    end
  end
end
