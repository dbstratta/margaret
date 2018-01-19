defmodule Margaret.Repo.Migrations.AddCommentsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:comments) do
      add(:content, :map, null: false)
      add(:author_id, references(:users), null: false)

      add(:story_id, references(:stories, on_delete: :delete_all), null: false)
      add(:parent_id, references(:comments, on_delete: :nilify_all))

      timestamps()
    end
  end
end
