defmodule Margaret.Repo.Migrations.AddMembershipsTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:memberships) do
      add(
        :customer_id,
        references(:customers, on_delete: :delete_all),
        null: false
      )

      add(:stripe_subscription_id, :string, null: false)

      timestamps()
    end

    create(unique_index(:memberships, [:customer_id]))
    create(unique_index(:memberships, [:stripe_subscription_id]))
  end
end
