defmodule Margaret.Repo.Migrations.AddNotificationsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    Margaret.Notifications.Notification.NotificationAction.create_type()

    create table(:notifications) do
      add(:actor_id, references(:users, on_delete: :nilify_all))
      add(:action, :notification_action, null: false)

      add(:story_id, references(:stories, on_delete: :delete_all))
      add(:comment_id, references(:comments, on_delete: :delete_all))
      add(:publication_id, references(:publications, on_delete: :delete_all))
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(
      # Check that only one object reference is not null.
      constraint(
        :notifications,
        :only_one_not_null_object,
        check: """
        (
          (story_id is not null)::integer +
          (comment_id is not null)::integer +
          (publication_id is not null)::integer +
          (user_id is not null)::integer
        ) = 1
        """
      )
    )
  end
end
