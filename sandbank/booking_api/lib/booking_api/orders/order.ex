defmodule BookingApi.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :error, :string
    field :status, :string
    field :total_value, :decimal
    field :items_quantity, :integer
    field :customer_id, :binary_id
    field :store_id, :binary_id
    field :payment_order_id, :binary_id
    field :items_classification_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:total_value, :status, :items_quantity, :error])
    |> validate_required([:total_value, :status, :items_quantity])
  end
end
