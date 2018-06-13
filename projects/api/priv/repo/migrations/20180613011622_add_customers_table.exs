defmodule Margaret.Repo.Migrations.AddCustomersTable do
  @moduledoc false

  use Ecto.Migration

  @doc false
  def change do
    create table(:customers, primary_key: false) do
      add(
        :user_id,
        references(:users, on_delete: :delete_all),
        null: false,
        primary_key: true
      )

      add(:stripe_customer_id, :string, null: false)

      timestamps()
    end

    create(unique_index(:customers, [:stripe_customer_id]))
  end
end
