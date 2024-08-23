defmodule BookingApi.Repo.Migrations.CreatePaymentOrders do
  use Ecto.Migration

  def change do
    create table(:payment_orders, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :value, :decimal
      add :status, :string

      timestamps(type: :utc_datetime)
    end
  end
end
