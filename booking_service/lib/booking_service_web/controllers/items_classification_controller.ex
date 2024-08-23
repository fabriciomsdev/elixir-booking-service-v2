defmodule BookingServiceWeb.ItemsClassificationController do
  use Phoenix.Controller,
  formats: [:html, :json]
  use BookingServiceWeb, :controller
  alias BookingService.ItemsClassification
  alias BookingServiceWeb.ItemsClassificationView


  def init(opts) do
    opts
  end

  def list(conn, _) do
    case ItemsClassification.list() do
      {:ok, items_classification} ->
        conn
        |> put_status(:ok)
        |> put_view(ItemsClassificationView)
        |> render("index.json", items_classifications: items_classification)
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(BookingServiceWeb.ErrorJSON)
        |> render("500.json", %{errors: reason})
    end
  end
end
