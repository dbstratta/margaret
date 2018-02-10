defmodule Margaret.Repo.Migrations.AddCollectionTagsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:collection_tags, primary_key: false) do
      add(
        :collection_id,
        references(:collections, on_delete: :delete_all),
        null: false,
        primary_key: true
      )

      add(:tag_id, references(:tags, on_delete: :delete_all), null: false, primary_key: true)
    end
  end
end
