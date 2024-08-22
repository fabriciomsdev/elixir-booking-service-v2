defmodule BookingApiWeb.OrdersController do
  use BookingApiWeb, :controller
  alias BookingApi.OrdersManagement
  alias BookingApiWeb.OrdersViews

  def init(opts) do
    opts
  end

  def new(conn, %{"user_id" => user_id, "store_id" => store_id}) do
    case BookingApi.OrdersManagement.start_order(store_id) do
      {:ok, order} ->
        conn
        |> put_status(:created)
        |> put_view(BookingApiWeb.OrdersViews)
        |> render("new.json", order: order)
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BookingApiWeb.ErrorJSON)
        |> render("422.json", %{errors: reason})
    end
  end

  def update(conn, %{"id" => id, "store" => %{ "id" => store_id }, "item" => item, "customer" => customer, "payment_order" => payment_order}) do
    case BookingApi.OrdersManagement.process_order(id, store_id, item, customer, payment_order) do
      {:ok, order} ->
        conn
        |> put_status(:ok)
        |> put_view(BookingApiWeb.OrdersViews)
        |> render("update.json", order: order)
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BookingApiWeb.ErrorJSON)
        |> render("422.json", %{errors: reason})
    end
  end


  def delete(conn, %{"id" => id}) do
    case BookingApi.OrdersManagement.cancel_order(id) do
      {:ok, order} ->
        conn
        |> put_status(:ok)
        |> render("delete.json", order: order)
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(BookingApiWeb.ErrorView, "422.json", %{errors: reason})
    end
  end
end
