defmodule BookingService.PaymentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BookingService.Payments` context.
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
      |> BookingService.Payments.create_payment_order()

    payment_order
  end
end
