defmodule BookingService.Orders.Order do
  @moduledoc """
  An Order represents a customer's order, including its status, total value,
  associated customer, store, payment order, and items.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "orders" do
    field :error, :string
    field :status, :string
    field :total_value, :decimal
    field :customer_id, :binary_id
    field :store_id, :binary_id
    field :payment_order_id, :binary_id
    has_many :items, BookingService.Orders.OrderItem

    timestamps(type: :utc_datetime)
  end

  def valid_status_list() do
    [
      "started",
      "filled",
      "paid",
      "booked",
      "failed",
      "canceled",
    ]
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :customer_id,
      :store_id,
      :payment_order_id,
      :total_value,
      :status,
      :error
    ])
    |> validate_required([:status, :total_value])
    |> put_change(:status, String.downcase(attrs.status))
    |> put_change(:status, String.trim(attrs.status))
    |> validate_inclusion(:status, valid_status_list())
  end

  def status_changeset(order, attrs) do
    order
    |> cast(attrs, [:status])
    |> validate_inclusion(:status, valid_status_list())
  end

  def value_changeset(order, attrs) do
    order
    |> cast(attrs, [:total_value])
    |> validate_number(:total_value, greater_than: 0)
  end
end
