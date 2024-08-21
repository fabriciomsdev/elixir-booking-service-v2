defmodule BookingApi.OrdersManagement do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias BookingApi.Repo
  alias BookingApi.Orders.Customer
  alias BookingApi.Orders.Order

  def start_order(store_id) do
    # Create order
    %Order{}
    |> Order.changeset(%{
      store_id: store_id,
      status: "started",
      total_value: 0.0,
      items_quantity: 0
    })
    |> Repo.insert()
  end

  def get_order!(id), do: Repo.get!(Order, id)

  def process_order(id, store_id, items, customer, payment_order) do
    # Update order
    #find order
    order = get_order!(id)

    # update order with items
    order
    |> Order.changeset(%{
      items: items,
      customer: customer,
      payment_order: payment_order,
      status: "filled"
    })
    |> Repo.update()

  end

  def process_order_payment(id, payment_order) do
    if (payment_order.status == "approved") do
      %Order{}
      |> Order.changeset(%{
        payment_order: payment_order,
        status: "paid"
      })
      |> Repo.update()
    else
      %Order{}
      |> Order.changeset(%{
        payment_order: payment_order,
        status: "error",
        error: "Payment was not approved -> " + payment_order.error
      })
      |> Repo.update()
    end
    # TODO: send a email for customer about order payment processing result
  end

  def book_order_with_store(id) do
    %Order{}
    |> Order.changeset(%{status: "booked"})
    |> Repo.update()
    # TODO: Send push notification for customer
    # TODO: send a email for customer about order booked
  end

  def cancel_order(id) do
    %Order{}
    |> Order.changeset(%{status: "canceled"})
    |> Repo.update()
    # TODO: send a email for customer about order canceled
  end
end
