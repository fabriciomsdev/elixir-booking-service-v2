defmodule BookingApi.Repo.Migrations.AddValueToStoreOnItemsClassification do
  use Ecto.Migration

  def change do
    alter table(:items_classification) do
      add :value_to_store, :decimal
    end
  end
end
