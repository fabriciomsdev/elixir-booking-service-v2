defmodule BookingServiceWeb.OrdersViews do
  def render("new.json", %{order: order}) do
    %{id: order.id, status: order.status }
  end

  def render("update.json", %{order: order}) do
    %{
      id: order.id,
      status: order.status,
      total_value: Decimal.to_float(order.total_value)
    }
  end

  def render("order.json", %{order: order}) do
    %{
      id: order.id,
      status: order.status,
      total_value: Decimal.to_float(order.total_value),
      error: order.error
    }
  end

  def render("delete.json", %{order: order}) do
    %{id: order.id, status: order.status }
  end

  def render("422.json", %{errors: errors}) do
    %{errors: errors}
  end
end
