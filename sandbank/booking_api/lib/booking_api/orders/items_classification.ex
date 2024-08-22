defmodule BookingApi.Orders.ItemsClassification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items_classification" do
    field :name, :string
    field :value_to_store, :decimal

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(items_classification, attrs) do
    items_classification
    |> cast(attrs, [:name, :value_to_store])
    |> validate_required([:name, :value_to_store])
    |> validate_number(:value_to_store, greater_than: 0)
    |> unique_constraint(:name)
    |> put_change(:name, String.downcase(attrs.name))
    |> put_change(:name, String.trim(attrs.name))
  end
end
