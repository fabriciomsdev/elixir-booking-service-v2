defmodule BookingApi.Payments do
  @moduledoc """
  The Payments context.
  """

  import Ecto.Query, warn: false
  alias BookingApi.Repo
  alias BookingApi.Payments.PaymentOrder
  import HTTPoison

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


  def process_payment_order(id) do
    # send order to payment api to create a payment order http://locahost:4001/api/payment_orders
    # process response from payment api
    # if payment order is approved then update payment order status to approved
    # if payment order is not approved then update payment order status to error with error message
    # return payment order updated

    payment_order = get_payment_order!(id)
    response = HTTPoison.post!("http://locahost:4001/api/payment_orders", body: payment_order)

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body: body}
        |> update_payment_order(%{status: "approved"})
      {:ok, %HTTPoison.Response{status_code: 420, body: body}} ->
        {:error, %PaymentOrder{}}
        |> update_payment_order(%{status: "error", error: "Payment was not approved -> " + body})
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %PaymentOrder{}}
        |> update_payment_order(%{status: "error", error: "Payment was not approved -> " + reason})
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
    payment_order
    |> PaymentOrder.changeset(attrs)
    |> Repo.update()
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
