defmodule BookingServiceWeb.OrdersUpdateSocket do
  use Phoenix.Socket

  ## Channels
  channel "order:*", BookingServiceWeb.OrderUpdatesChannel

  # This function is called when a client connects to the socket.
  # You can use it to authenticate the user and assign default values to the socket.
  def connect(%{"token" => token}, socket, _connect_info) do
    # TODO: authenticate
    {:ok, socket}
  end

  def connect(_params, _socket, _connect_info) do
    :error
  end

  # This function is called when a client disconnects from the socket.
  def id(_socket), do: nil
end
