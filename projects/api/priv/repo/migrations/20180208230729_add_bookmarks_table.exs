defmodule Margaret.Repo.Migrations.AddBookmarksTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:bookmarks) do
      add(:user_id, references(:users, on_delete: :delete_all), null: false)

      # Bookmarkables
      add(:collection_id, references(:collections, on_delete: :delete_all))
      add(:story_id, references(:stories, on_delete: :delete_all))
      add(:comment_id, references(:comments, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:bookmarks, [:user_id, :collection_id]))
    create(unique_index(:bookmarks, [:user_id, :story_id]))
    create(unique_index(:bookmarks, [:user_id, :comment_id]))

    create(
      constraint(
        :bookmarks,
        :only_one_not_null_bookmarkable,
        check: """
        (
          (collection_id is not null)::integer +
          (story_id is not null)::integer +
          (comment_id is not null)::integer
        ) = 1
        """
      )
    )
  end
end
