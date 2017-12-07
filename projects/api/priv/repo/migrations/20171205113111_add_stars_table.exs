defmodule Margaret.Repo.Migrations.AddStarsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:stars) do
      add :user_id, references(:users), null: false

      timestamps()
    end
  end
end
