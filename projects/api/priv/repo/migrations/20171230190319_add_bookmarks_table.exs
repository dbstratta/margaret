defmodule Margaret.Repo.Migrations.AddBookmarksTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:bookmarks) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      add(:story_id, references(:stories, on_delete: :delete_all))
      add(:comment_id, references(:comments, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:bookmarks, [:user_id, :story_id]))
    create(unique_index(:bookmarks, [:user_id, :comment_id]))

    create(
      constraint(
        :bookmarks,
        :only_one_not_null_bookmarkable,
        check: """
          story_id is not null and comment_id is null or
          story_id is null and comment_id is not null
        """
      )
    )
  end
end
