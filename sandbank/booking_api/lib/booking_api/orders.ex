defmodule BookingApi.OrdersManagement do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias BookingApi.Repo
  alias BookingApi.Orders.Customer
  alias BookingApi.Orders.Order
  alias BookingApi.Payments
  alias BookingApi.Stores
  alias BookingApi.Orders.ItemsClassification
  alias BookingApi.BussinessValidationError

  def get_orders_update_queue, do: "order_update"

  def get_store_by_id(store_id) do
    store = Stores.get_store(store_id)
    if store == nil do
      raise %BussinessValidationError{message: "Store not found"}
    end

    store
  end

  def start_order(store_id) do
    store = get_store_by_id(store_id)

    order = %Order{}
    |> Order.changeset(%{
      store_id: store.id,
      status: "started",
      total_value: 0.0,
      items_quantity: 0
    })
    |> Repo.insert()
    |> publish_order_update

    order
  end

  def get_order(id) do
    order = Repo.get(Order, id)

    if order == nil do
      raise %BussinessValidationError{message: "Order not found"}
    end

    order
  end

  def register_a_customer(attrs) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  def get_item_classification_by_name(name) do
    classfication = Repo.one(from i in ItemsClassification, where: i.name == ^name)

    if classfication == nil do
      raise %BussinessValidationError{message: "Classification of Item to store not found" }
    end

    classfication
  end

  def publish_order_update(order) do
    Phoenix.PubSub.broadcast(
      BookingApi.PubSub,
      get_orders_update_queue(),
      {:do_background_task, order}
    )
    order
  end

  def process_order(id, store_id, item, customer, payment_data) do
    order = get_order(id)
    item_classification = get_item_classification_by_name(item.name)
    store = get_store_by_id(store_id)

    {:ok, customer} = register_a_customer(customer)
    {:ok, payment_order} = Payments.create_payment_order(%{
      order_id: order.id,
      value: Decimal.to_float(item_classification.value_to_store) * item.quantity,
      status: "pending"
    })

    order
    |> Order.changeset(%{
      customer_id: customer.id,
      payment_order_id: payment_order.id,
      store_id: store.id,
      items_classification_id: item_classification.id,
      total_value: payment_order.value,
      status: "filled",
      items_quantity: item.quantity
    })
    |> Repo.update()
    |> publish_order_update

    Payments.send_payment_order_to_processing_queue(payment_order, payment_data)

    order
  end

  def set_order_as_paid(order) do
    order
    |> Order.changeset(%{status: "paid"})
    |> Repo.update()
    |> publish_order_update
  end

  def book_order(order) do
    order
    |> Order.changeset(%{status: "booked"})
    |> Repo.update()
    |> publish_order_update
  end

  def cancel_order(order) do
    order
    |> Order.change_status("canceled")
    |> Repo.update()
    |> publish_order_update
  end

  def set_order_as_failed(order, error) do
    order
    |> Order.changeset(%{status: "failed", error: error})
    |> Repo.update()
    |> publish_order_update
  end

  def book_order_with_store(id) do
    %Order{}
    |> Order.changeset(%{status: "booked"})
    |> Repo.update()
    # TODO: Send push notification for customer
    # TODO: send a email for customer about order booked
  end

  def cancel_order(id) do
    get_order(id)
    |> Order.changeset(%{status: "canceled"})
    |> Repo.update()
    # TODO: send a email for customer about order canceled
  end
end
