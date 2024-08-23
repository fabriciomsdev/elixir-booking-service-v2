defmodule BookingApi.Repo.Migrations.RemoveQuantityFieldFromOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      remove :items_quantity
    end
  end
end
