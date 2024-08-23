defmodule BookingApi.Repo.Migrations.AddClassificationOnOrderItem do
  use Ecto.Migration

  def change do
    # alter table orders_items add classification_id, rename items_quantity to quantity
    alter table(:orders_items) do
      add :classification_id, :binary_id
    end

    rename table(:orders_items), :quantity, to: :quantity
  end
end
