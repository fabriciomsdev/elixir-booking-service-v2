defmodule BookingApi.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :total_value, :decimal
      add :status, :string
      add :error, :string
      add :customer_id, references(:customers, on_delete: :nothing, type: :binary_id)
      add :store_id, references(:stores, on_delete: :nothing, type: :binary_id)
      add :payment_order_id, references(:payment_orders, on_delete: :nothing, type: :binary_id)
      add :items_classification_id, references(:items_classification, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:customer_id])
    create index(:orders, [:store_id])
    create index(:orders, [:payment_order_id])
    create index(:orders, [:items_classification_id])
  end
end
