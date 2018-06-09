defmodule Margaret.Repo.Migrations.AddMessagesTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:messages) do
      add(:content, :map, null: false)

      add(:sender_id, references(:users, on_delete: :delete_all), null: false)
      add(:recipient_id, references(:users, on_delete: :delete_all), null: false)

      timestamps()
    end

    create(index(:messages, [:sender_id, :recipient_id]))
  end
end
