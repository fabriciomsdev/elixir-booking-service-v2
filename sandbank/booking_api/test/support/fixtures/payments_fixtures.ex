defmodule BookingApi.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BookingApi.Payments` context.
  """

  @doc """
  Generate a payment_order.
  """
  def payment_order_fixture(attrs \\ %{}) do
    {:ok, payment_order} =
      attrs
      |> Enum.into(%{
        status: "some status",
        value: "120.5"
      })
      |> BookingApi.Payments.create_payment_order()

    payment_order
  end
end
