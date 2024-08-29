defmodule BookingServiceWeb.OrderUpdatesChannel do
  @moduledoc """
  This module handles the WebSocket channel for order updates.

  It allows clients to join a channel for a specific order and receive real-time updates
  about the order status.
  """
  use BookingServiceWeb, :channel

  def join("order:"<> order_id, _message, socket) do
    # TODO: verify user is the owner of the order
    IO.puts("Joining order: #{order_id}")
    {:ok, assign(socket, :order_id, order_id)}
  end

  def handle_info(%{event: "order_update", order: order}, socket) do
    broadcast!(socket, "order_update", %{order: order})
    {:noreply, socket}
  end
end
