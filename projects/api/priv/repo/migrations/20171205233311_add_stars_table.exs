defmodule Margaret.Repo.Migrations.AddStarsTable do
  use Ecto.Migration

  def change do
    create table(:stars) do
      add :user_id, references(:users), null: false

      timestamps()
    end
  end
end
