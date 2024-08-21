defmodule BookingApi.OrdersTest do
  use BookingApi.DataCase
  alias BookingApi.Orders
  alias BookingApi.OrdersManagement
  alias BookingApi.Orders.Customer
  alias BookingApi.Orders.Order
  alias BookingApi.Stores.Store
  alias BookingApi.Payment.PaymentOrder


  describe "orders" do
    alias BookingApi.OrdersManagement

    import BookingApi.OrdersFixtures

    @invalid_attrs %{error: nil, status: nil, total_value: nil, items_quantity: nil}

    def create_customer() do
      %Customer{}
      |> Customer.changeset(%{name: "John Doe", email: "jonhdoe@gmail.com", phone: "123456789"})
      |> Repo.insert()
    end

    def create_store() do
      %Store{}
      |> Store.changeset(%{name: "Store 1", address: "123 Main St"})
      |> Repo.insert()
    end

    test "start a order" do
      {:ok, store} = create_store()

      # create a order
      assert {:ok, order} = OrdersManagement.start_order(store.id)
      assert order.status == "started"
      assert order.id != nil
    end

    test "fill a order with necessary data to process" do
      # create a fake customer
      customer = create_customer()
      {:ok, store} = create_store()

      # create a order
      assert {:ok, order} = OrdersManagement.start_order(store.id)

      # fill order with necessary data to process
      items = [%{id: 1, name: "Bags Storage", price: 10.0, quantity: 2}]
      customer = %Customer{name: "John Doe", email: "fabricioms.dev@gmail.com", phone: "123456789"}

      assert {:ok, order} = OrdersManagement.process_order(order.id, store.id, items, customer, nil)
    end
  end
end
