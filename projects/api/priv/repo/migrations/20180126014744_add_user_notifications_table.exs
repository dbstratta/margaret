defmodule Margaret.Repo.Migrations.AddUserNotificationsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:user_notifications, primary_key: false) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false, primary_key: true)

      add(
        :notification_id,
        references(:notifications, on_delete: :delete_all),
        null: false,
        primary_key: true
      )

      add(:read_at, :naive_datetime)
    end

    create(index(:user_notifications, [:user_id]))
  end
end
