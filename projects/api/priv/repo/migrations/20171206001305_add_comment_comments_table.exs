defmodule Margaret.Repo.Migrations.AddCommentCommentsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:comment_comments) do
      add :parent_comment_id, references(:comments), null: false
      add :comment_id, references(:comments), null: false

      timestamps()
    end
  end
end
