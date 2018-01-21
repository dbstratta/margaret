defmodule Margaret.Repo.Migrations.AddFollowsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:follows) do
      add(:follower_id, references(:users, on_delete: :delete_all), null: false)

      add(:user_id, references(:users, on_delete: :delete_all))
      add(:publication_id, references(:publications, on_delete: :delete_all))

      timestamps()
    end

    create(unique_index(:follows, [:follower_id, :user_id]))
    create(unique_index(:follows, [:follower_id, :publication_id]))

    create(
      constraint(
        :follows,
        :only_one_not_null_followable,
        check: """
          user_id is not null and publication_id is null or
          user_id is null and publication_id is not null
        """
      )
    )

    create(constraint(:follows, :cannot_follow_follower, check: "follower_id != user_id"))
  end
end
