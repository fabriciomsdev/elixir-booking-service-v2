defmodule BookingService.OrdersUpdateProcessorWorker do
  use GenServer
  alias BookingService.OrdersManagement
  alias BookingService.Payments

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    # Subscribe to the topic
    Phoenix.PubSub.subscribe(BookingService.PubSub, OrdersManagement.get_orders_update_queue())
    {:ok, %{}}
  end

  def handle_info({:do_background_task, data}, state) do
    # Perform your background task here
    Task.start(fn -> process_data(data) end)

    {:noreply, state}
  end

  defp process_data(data) do
    order = data
    channel = "order:#{order.id}"
    IO.inspect(order, label: "Processing order in the background")

    order = %{
      order_id: order.id,
      status: order.status,
      store_id: order.store_id
    }

    Phoenix.PubSub.broadcast(
      BookingService.PubSub,
      channel,
      %{event: "order_update", order: order}
    )
  end
end
