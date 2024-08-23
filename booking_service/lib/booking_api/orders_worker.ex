defmodule BookingApi.OrdersUpdateProcessorWorker do
  use GenServer
  alias BookingApi.OrdersManagement
  alias BookingApi.Payments

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    # Subscribe to the topic
    Phoenix.PubSub.subscribe(BookingApi.PubSub, OrdersManagement.get_orders_update_queue())
    {:ok, %{}}
  end

  def handle_info({:do_background_task, data}, state) do
    # Perform your background task here
    Task.start(fn -> process_data(data) end)

    {:noreply, state}
  end

  defp process_data(data) do
    # Background task processing logic
    order = data
    IO.inspect(order, label: "Processing in the background")
  end
end
