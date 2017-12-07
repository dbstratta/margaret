defmodule Margaret.Repo.Migrations.AddCommentStarsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:comment_stars, primary_key: false) do
      add :comment_id, references(:comments), null: false
      add :star_id, references(:stars), null: false
    end

    create unique_index(:comment_stars, [:comment_id, :star_id])
  end
end
