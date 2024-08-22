defmodule BookingApi.Repo.Migrations.AddOrderIdToPaymentOrder do
  use Ecto.Migration

  def change do
    alter table(:payment_orders) do
      add :order_id, :binary_id
    end
  end
end
