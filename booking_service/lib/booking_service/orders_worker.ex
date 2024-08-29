defmodule BookingService.OrdersUpdateProcessorWorker do
  @moduledoc """
  This module defines a GenServer that processes order updates in the background.

  It subscribes to a PubSub topic for order updates and handles background tasks
  for processing order data.
  """
  use GenServer
  require Logger
  alias BookingService.OrdersManagement
  alias BookingService.Payments

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Phoenix.PubSub.subscribe(BookingService.PubSub, OrdersManagement.get_orders_update_queue())
    {:ok, %{}}
  end

  def handle_info({:do_background_task, data}, state) do
    Task.start(fn -> process_data(data) end)

    {:noreply, state}
  end

  defp process_data(data) do
    order = data
    Logger.info("Processing order #{order.id} on status #{order.status} in the background")

    channel = "order:#{order.id}"
    order = %{
      order_id: order.id,
      status: order.status,
      store_id: order.store_id,
      error: order.error,
    }

    Phoenix.PubSub.broadcast(
      BookingService.PubSub,
      channel,
      %{event: "order_update", order: order}
    )
  end
end
