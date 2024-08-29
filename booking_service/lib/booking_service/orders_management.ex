defmodule BookingService.OrdersManagement do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  require Logger
  alias BookingService.Repo
  alias BookingService.Orders.Customer
  alias BookingService.Orders.Order
  alias BookingService.Payments
  alias BookingService.Stores
  alias BookingService.Orders.OrderItem
  alias BookingService.Items.Classification
  alias BookingService.BussinessValidationError

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
    })
    |> Repo.insert!()
    |> publish_order_update()

    {:ok, order}
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
    if name == nil do
      raise %BussinessValidationError{message: "You need to inform the name of the item to store"}
    end

    classfication = Repo.one(from i in Classification, where: i.name == ^name)

    if classfication == nil do
      current_classifications = Repo.all(Classification)
      current_classifications_as_str = Enum.map(current_classifications, & &1.name)

      raise %BussinessValidationError{message: "Classification of Item to store not found" }
    end

    classfication
  end

  def publish_order_update(order) do
    Phoenix.PubSub.broadcast(
      BookingService.PubSub,
      get_orders_update_queue(),
      {:do_background_task, order}
    )

    order
  end

  def ask_order_payment(payment_order, payment_data) do
    Payments.send_payment_order_to_processing_queue(payment_order, payment_data)
  end

  def validate_current_order_status(%{"status" => current_status}, status) do
    sucess_flow = [
      "started",
      "filled",
      "paid",
      "booked",
    ]

    if current_status == "booked" do
      raise %BussinessValidationError{message: "Order already booked"}
    end

    if current_status == "canceled" do
      raise %BussinessValidationError{message: "Order already canceled, you need to open a new order"}
    end
  end

  def save_items_of_order(order, items) do
    for %{"name" => name, "quantity" => quantity} <- items do
      # TODO: optmize doing only one query to get all items classification
      item_classification = get_item_classification_by_name(name)
      Repo.insert(%OrderItem{
        order_id: order.id,
        classification_id: item_classification.id,
        quantity: quantity,
        total_value: Decimal.to_float(item_classification.value_to_store) * quantity,
      })
    end

    order
  end

  def calculate_costs(order, items) do
    order_items = []
    total_order_value = Enum.reduce(items, 0.0, fn %{"name" => name, "quantity" => quantity}, acc ->
      item_classification = get_item_classification_by_name(name)
      item_value = Decimal.to_float(item_classification.value_to_store) * quantity
      acc + item_value
    end)
    Logger.info("Total order value: #{total_order_value}")

    order
    |> Order.value_changeset(%{
      total_value: total_order_value
    })
  end

  def create_payment_order(order) do
    {:ok, payment_order} = Payments.create_payment_order(%{
      order_id: order.id,
      value: order.total_value,
      status: "pending"
    })

    payment_order
  end

  def process_order(id, store_id, items, customer, payment_data) do
    order = get_order(id)
    store = get_store_by_id(store_id)
    next_status = "filled"

    {:ok, customer} = register_a_customer(customer)

    {:ok, order} = order
      |> Order.changeset(%{
        customer_id: customer.id,
        store_id: store.id,
        status: next_status,
      })
      |> calculate_costs(items)
      |> Repo.update

      order = order
      |> save_items_of_order(items)
      |> publish_order_update

      payment_order = order
      |> create_payment_order
      |> ask_order_payment(payment_data)

      {:ok, get_order(order.id)}
  end

  def set_order_as_paid(order) do
    {:ok, order} = order
    |> Order.status_changeset(%{status: "paid"})
    |> Repo.update()

    publish_order_update(order)
  end

  def book_order(order) do
    {:ok, order} = order
    |> Order.status_changeset(%{status: "booked"})
    |> Repo.update()
    publish_order_update(order)
  end

  def cancel_order(order) do
    order
    |> Order.change_status("canceled")
    |> Repo.update()
    |> publish_order_update
  end

  def set_order_as_failed(order, error) do
    {:ok, order} = order
    |> Order.changeset(%{status: "failed", error: error})
    |> Repo.update()

    publish_order_update(order)
  end

  # TODO: Send push notification for customer
  # TODO: send a email for customer about order booked
  def book_order_with_store(id) do
    %Order{}
    |> Order.changeset(%{status: "booked"})
    |> Repo.update()
  end

  def cancel_order(id) do
    # TODO: send a email for customer about order canceled
    get_order(id)
    |> Order.changeset(%{status: "canceled"})
    |> Repo.update()
  end
end
