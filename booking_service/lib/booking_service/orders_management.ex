defmodule BookingService.OrdersManagement do
  @moduledoc """
    The Orders business context.
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

  @doc """
  Returns the queue name for order updates.
  """
  def get_orders_update_queue, do: "order_update"

  @doc """
  Retrieves a store by its ID.

  Raises `BussinessValidationError` if the store is not found.
  """
  def get_store_by_id(store_id) do
    store = Stores.get_store(store_id)
    if store == nil do
      raise %BussinessValidationError{message: "Store not found"}
    end

    store
  end

  @doc """
  Starts a new order for the given store ID.

  Returns `{:ok, order}`.
  """
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

  @doc """
  Retrieves an order by its ID.

  Raises `BussinessValidationError` if the order is not found.
  """
  def get_order(id) do
    order = Repo.get(Order, id)

    if order == nil do
      raise %BussinessValidationError{message: "Order not found"}
    end

    order
  end

  @doc """
  Registers a new customer with the given attributes.

  Returns `{:ok, customer}` or `{:error, changeset}`.
  """
  def register_a_customer(attrs) do
    %Customer{}
    |> Customer.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Retrieves an item classification by its name.

  Raises `BussinessValidationError` if the name is not provided or the classification is not found.
  """
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

  @doc """
  Publishes an order update to the order update queue.

  Returns the order.
  """
  def publish_order_update(order) do
    Phoenix.PubSub.broadcast(
      BookingService.PubSub,
      get_orders_update_queue(),
      {:do_background_task, order}
    )

    order
  end

  @doc """
  Sends a payment order to the processing queue.
  """
  def ask_order_payment(payment_order, payment_data) do
    Payments.send_payment_order_to_processing_queue(payment_order, payment_data)
  end

  @doc """
  Validates the current order status against the provided status.

  Raises `BussinessValidationError` if the order is already booked or canceled.
  """
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

  @doc """
  Saves the items of an order.

  Returns the order.
  """
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

  @doc """
  Calculates the total costs of an order based on its items.

  Returns the updated order changeset.
  """
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

  @doc """
  Creates a payment order for the given order.

  Returns `{:ok, payment_order}`.
  """
  def create_payment_order(order) do
    {:ok, payment_order} = Payments.create_payment_order(%{
      order_id: order.id,
      value: order.total_value,
      status: "pending"
    })

    payment_order
  end

  @doc """
  Processes an order by updating its status, saving items, and creating a payment order.

  Returns `{:ok, order}`.
  """
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

  @doc """
  Sets the status of an order to "paid".

  Returns `{:ok, order}`.
  """
  def set_order_as_paid(order) do
    {:ok, order} = order
    |> Order.status_changeset(%{status: "paid"})
    |> Repo.update()

    publish_order_update(order)
  end

  @doc """
  Books an order by setting its status to "booked".

  Returns `{:ok, order}`.
  """
  def book_order(order) do
    {:ok, order} = order
    |> Order.status_changeset(%{status: "booked"})
    |> Repo.update()
    publish_order_update(order)
  end

  @doc """
  Cancels an order by setting its status to "canceled".

  Returns `{:ok, order}`.
  """
  def cancel_order(order) do
    order
    |> Order.change_status("canceled")
    |> Repo.update()
    |> publish_order_update
  end

  @doc """
  Sets the status of an order to "failed" with an error message.

  Returns `{:ok, order}`.
  """
  def set_order_as_failed(order, error) do
    {:ok, order} = order
    |> Order.changeset(%{status: "failed", error: error})
    |> Repo.update()

    publish_order_update(order)
  end

  @doc """
  Books an order with the store by setting its status to "booked".

  Returns `{:ok, order}`.
  """
  def book_order_with_store(id) do
    # TODO: Send push notification for customer
    # TODO: send a email for customer about order booked
    %Order{}
    |> Order.changeset(%{status: "booked"})
    |> Repo.update()
  end

  @doc """
  Cancels an order by its ID by setting its status to "canceled".

  Returns `{:ok, order}`.
  """
  def cancel_order(id) do
    # TODO: send a email for customer about order canceled
    get_order(id)
    |> Order.changeset(%{status: "canceled"})
    |> Repo.update()
  end
end
