defmodule Margaret.Repo.Migrations.AddUserNotificationsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:user_notifications) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      add(:notification_id, references(:notifications, on_delete: :delete_all), null: false)
      add(:read_at, :naive_datetime)
    end

    create(unique_index(:user_notifications, [:user_id, :notification_id]))
    create(index(:user_notifications, [:user_id]))
  end
end
