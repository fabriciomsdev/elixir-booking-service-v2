defmodule BookingApi.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BookingApi.Orders` context.
  """

  @doc """
  Generate a customer.
  """
  def customer_fixture(attrs \\ %{}) do
    {:ok, customer} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name",
        phone: "some phone"
      })
      |> BookingApi.Orders.create_customer()

    customer
  end

  @doc """
  Generate a items_classification.
  """
  def items_classification_fixture(attrs \\ %{}) do
    {:ok, items_classification} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> BookingApi.Orders.create_items_classification()

    items_classification
  end

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        error: "some error",
        items_quantity: 42,
        status: "some status",
        total_value: "120.5"
      })
      |> BookingApi.Orders.start_order()

    order
  end

  @doc """
  Generate a order_item.
  """
  def order_item_fixture(attrs \\ %{}) do
    {:ok, order_item} =
      attrs
      |> Enum.into(%{
        quantity: 42,
        total_value: "120.5"
      })
      |> BookingApi.Orders.create_order_item()

    order_item
  end
end
