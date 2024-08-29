defmodule BookingServiceWeb.OrdersController do
  use BookingServiceWeb, :controller
  alias BookingService.OrdersManagement
  alias BookingServiceWeb.OrdersViews

  def init(opts) do
    opts
  end

  def new(conn, %{"store_id" => store_id}) do
    case OrdersManagement.start_order(store_id) do
      {:ok, order} ->
        conn
        |> put_status(:created)
        |> put_view(BookingServiceWeb.OrdersViews)
        |> render("new.json", order: order)
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BookingServiceWeb.ErrorJSON)
        |> render("422.json", %{errors: reason})
    end
  end

  def update(conn, %{"id" => id, "store" => %{"id" => store_id}, "items" => items, "customer" => customer, "payment_order" => payment_order}) do
    case OrdersManagement.process_order(id, store_id, items, customer, payment_order) do
      {:ok, order} ->
        conn
        |> put_status(:ok)
        |> put_view(BookingServiceWeb.OrdersViews)
        |> render("update.json", order: order)
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BookingServiceWeb.ErrorJSON)
        |> render("422.json", %{errors: reason})
    end
  end


  def delete(conn, %{"id" => id}) do
    case OrdersManagement.cancel_order(id) do
      {:ok, order} ->
        conn
        |> put_status(:ok)
        |> render("delete.json", order: order)
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BookingServiceWeb.ErrorView, "422.json", %{errors: reason})
    end
  end

  def find(conn, %{"id" => id}) do
    case OrdersManagement.get_order(id) do
      order ->
        conn
        |> put_status(:ok)
        |> put_view(BookingServiceWeb.OrdersViews)
        |> render("order.json", order: order)
      nil ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BookingServiceWeb.ErrorJSON)
        |> render("404.json", %{errors: "Order not found"})
    end
  end
end
