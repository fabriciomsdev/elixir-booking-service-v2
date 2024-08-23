# defmodule BookingService.PaymentsTest do
#   use BookingService.DataCase

#   alias BookingService.Payments

#   describe "payment_orders" do
#     alias BookingService.Payments.PaymentOrder

#     import BookingService.PaymentsFixtures

#     @invalid_attrs %{status: nil, value: nil}

#     test "list_payment_orders/0 returns all payment_orders" do
#       payment_order = payment_order_fixture()
#       assert Payments.list_payment_orders() == [payment_order]
#     end

#     test "get_payment_order!/1 returns the payment_order with given id" do
#       payment_order = payment_order_fixture()
#       assert Payments.get_payment_order!(payment_order.id) == payment_order
#     end

#     test "create_payment_order/1 with valid data creates a payment_order" do
#       valid_attrs = %{status: "some status", value: "120.5"}

#       assert {:ok, %PaymentOrder{} = payment_order} = Payments.create_payment_order(valid_attrs)
#       assert payment_order.status == "some status"
#       assert payment_order.value == Decimal.new("120.5")
#     end

#     test "create_payment_order/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Payments.create_payment_order(@invalid_attrs)
#     end

#     test "update_payment_order/2 with valid data updates the payment_order" do
#       payment_order = payment_order_fixture()
#       update_attrs = %{status: "some updated status", value: "456.7"}

#       assert {:ok, %PaymentOrder{} = payment_order} = Payments.update_payment_order(payment_order, update_attrs)
#       assert payment_order.status == "some updated status"
#       assert payment_order.value == Decimal.new("456.7")
#     end

#     test "update_payment_order/2 with invalid data returns error changeset" do
#       payment_order = payment_order_fixture()
#       assert {:error, %Ecto.Changeset{}} = Payments.update_payment_order(payment_order, @invalid_attrs)
#       assert payment_order == Payments.get_payment_order!(payment_order.id)
#     end

#     test "delete_payment_order/1 deletes the payment_order" do
#       payment_order = payment_order_fixture()
#       assert {:ok, %PaymentOrder{}} = Payments.delete_payment_order(payment_order)
#       assert_raise Ecto.NoResultsError, fn -> Payments.get_payment_order!(payment_order.id) end
#     end

#     test "change_payment_order/1 returns a payment_order changeset" do
#       payment_order = payment_order_fixture()
#       assert %Ecto.Changeset{} = Payments.change_payment_order(payment_order)
#     end
#   end
# end
