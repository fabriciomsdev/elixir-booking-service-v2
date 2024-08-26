defmodule BookingService.Payments do
  @moduledoc """
  The Payments context.
  """
  require Logger
  import HTTPoison
  import Ecto.Query, warn: false
  alias BookingService.Repo
  alias BookingService.Payments.PaymentOrder
  alias BookingService.PaymentsProcessorWorker

  def get_payment_update_queue, do: "payment_order_update"

  @doc """
  Gets a single payment_order.

  Raises `Ecto.NoResultsError` if the Payment order does not exist.

  ## Examples

      iex> get_payment_order!(123)
      %PaymentOrder{}

      iex> get_payment_order!(456)
      ** (Ecto.NoResultsError)

  """
  def get_payment_order!(id), do: Repo.get!(PaymentOrder, id)

  @doc """
  Creates a payment_order.

  ## Examples

      iex> create_payment_order(%{field: value})
      {:ok, %PaymentOrder{}}

      iex> create_payment_order(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_payment_order(attrs \\ %{}) do
    %PaymentOrder{}
    |> PaymentOrder.changeset(attrs)
    |> Repo.insert()
  end


  def get_pending_payments_orders do
    Repo.all(from p in PaymentOrder, where: p.status == "pending")
  end

  def send_payment_order_to_processing_queue(payment_order, payment_data \\ nil) do
    Phoenix.PubSub.broadcast(
      BookingService.PubSub,
      get_payment_update_queue(),
      {:do_background_task, %{ order: payment_order, payment_data: payment_data }}
    )
  end

  def process_payment_order(id, %{ "credit_card" => credit_card, "cvv" => cvv, "expiration_date" => expiration_date }) do
    # send order to payment api to create a payment order http://locahost:4001/api/payment_orders
    # process response from payment api
    # if payment order is approved then update payment order status to approved
    # if payment order is not approved then update payment order status to error with error message
    # return payment order updated

    payment_order = get_payment_order!(id)
    IO.puts("Processing payment order #{payment_order.status}")

    payload = %{
      "credit_card" => credit_card,
      "cvv" => cvv,
      "expiration_date" => expiration_date,
      "amount" => Decimal.to_float(payment_order.value)
    } |> Jason.encode!()
    headers = [{"Content-Type", "application/json"}]
    payment_service_url = Application.get_env(:booking_service, :payment_service_url)

    response = HTTPoison.post!(payment_service_url, payload, headers)

    case response do
      %HTTPoison.Response{status_code: 200, body: body} ->
        update_payment_order(payment_order, %{status: "approved"})
      %HTTPoison.Response{status_code: 400, body: body} ->
        update_payment_order(payment_order, %{status: "error", error: "Payment was not approved"})
      %HTTPoison.Error{reason: reason} ->
        update_payment_order(payment_order, %{status: "error", error: "Payment was not approved"})
    end

  end

  @doc """
  Updates a payment_order.

  ## Examples

      iex> update_payment_order(payment_order, %{field: new_value})
      {:ok, %PaymentOrder{}}

      iex> update_payment_order(payment_order, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_payment_order(%PaymentOrder{} = payment_order, attrs) do
    {:ok, payment_order} = payment_order
    |> PaymentOrder.changeset(attrs)
    |> Repo.update()

    BookingService.Payments.send_payment_order_to_processing_queue(payment_order)
  end


  @doc """
  Returns an `%Ecto.Changeset{}` for tracking payment_order changes.

  ## Examples

      iex> change_payment_order(payment_order)
      %Ecto.Changeset{data: %PaymentOrder{}}

  """
  def change_payment_order(%PaymentOrder{} = payment_order, attrs \\ %{}) do
    PaymentOrder.changeset(payment_order, attrs)
  end
end
