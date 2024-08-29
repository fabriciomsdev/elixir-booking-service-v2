defmodule BookingService.Payments.PaymentOrder do
  @moduledoc """
  A PaymentOrder represents a payment transaction associated with an order.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "payment_orders" do
    field :status, :string
    field :value, :decimal
    field :order_id, :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(payment_order, attrs) do
    payment_order
    |> cast(attrs, [:value, :status, :order_id])
    |> validate_required([:value, :status])
  end
end
