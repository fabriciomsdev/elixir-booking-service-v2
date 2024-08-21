defmodule BookingApi.Orders.ItemsClassification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items_classification" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(items_classification, attrs) do
    items_classification
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
