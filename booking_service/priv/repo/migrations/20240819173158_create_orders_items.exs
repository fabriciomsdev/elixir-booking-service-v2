defmodule BookingApi.Repo.Migrations.CreateOrdersItems do
  use Ecto.Migration

  def change do
    create table(:orders_items, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :total_value, :decimal
      add :quantity, :integer
      add :order_id, references(:orders, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:orders_items, [:order_id])
  end
end
