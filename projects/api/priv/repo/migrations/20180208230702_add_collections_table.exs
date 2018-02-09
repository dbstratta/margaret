defmodule Margaret.Repo.Migrations.AddCollectionsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:collections) do
      add(:title, :string, null: false)

      add(:image, :string)
      add(:subtitle, :string, null: false)
      add(:description, :string, size: 512)

      add(:slug, :string, null: false)

      add(:author_id, references(:users, on_delete: :delete_all), null: false)

      add(:publication_id, references(:publications, on_delete: :nilify_all))

      timestamps()
    end

    create(unique_index(:collections, [:slug]))
    create(index(:collections, [:author_id]))

    create(
      index(
        :collections,
        [:publication_id],
        where: "publication_id is not null",
        name: :publication_collections
      )
    )
  end
end
