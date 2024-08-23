defmodule BookingApi.Repo.Migrations.RemoveClassificationFromOrder do
  use Ecto.Migration

  def change do
    alter table(:orders) do
      remove :items_classification_id
    end
  end
end
