defmodule BookingService.Orders.OrderItem do
  @moduledoc """
  An OrderItem represents an item within an order, including its total value,
  quantity, and associations with an order and classification.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders_items" do
    field :total_value, :decimal
    field :quantity, :integer
    field :order_id, :binary_id
    field :classification_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order_item, attrs) do
    order_item
    |> cast(attrs, [:total_value, :quantity])
    |> validate_required([:total_value, :quantity])
  end
end
