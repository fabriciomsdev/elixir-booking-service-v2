defmodule BookingService.PaymentsProcessorWorker do
  use GenServer
  alias BookingService.Payments
  alias BookingService.OrdersManagement

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    # Subscribe to the topic
    Phoenix.PubSub.subscribe(BookingService.PubSub, Payments.get_payment_update_queue())
    {:ok, %{}}
  end

  def handle_info({:do_background_task, data}, state) do
    # Perform your background task here
    Task.start(fn -> process_data(data) end)

    {:noreply, state}
  end

  defp process_data(data) do
    # Background task processing logic
    IO.inspect(data, label: "Processing in the background")
    payment_order = data.order

    if payment_order.status == "pending" do
      # Here we would process the payment order and update the status
      # of the payment order to "processed" or "failed" based on the
      # payment data received.
      payment_data = data.payment_data
      Payments.process_payment_order(payment_order.id, payment_data)
    end

    if payment_order.status == "approved" do
      IO.puts("Payment order approved -> #{payment_order.order_id}")

      # todo: decouple this logic to a separate module
      order = OrdersManagement.get_order(payment_order.order_id)
      OrdersManagement.set_order_as_paid(order)
      OrdersManagement.book_order(order)
    end

    if payment_order.status == "error" do
      IO.puts("Payment order failed -> #{payment_order.order_id}")

      # todo: decouple this logic to a separate module
      order = OrdersManagement.get_order(payment_order.order_id)
              |> OrdersManagement.set_order_as_failed("Payment order failed")
    end
  end
end
