defmodule BookingServiceWeb.OrderUpdatesChannel do
  use BookingServiceWeb, :channel

  def join("order:"<> order_id, _message, socket) do
    IO.puts("Joining order: #{order_id}")
    {:ok, assign(socket, :order_id, order_id)}
  end

  def handle_info(%{event: "order_update", order: order}, socket) do
    broadcast!(socket, "order_update", %{order: order})
    {:noreply, socket}
  end
end
