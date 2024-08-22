defmodule BookingApi.OrdersTest do
  use BookingApi.DataCase
  alias BookingApi.Orders
  alias BookingApi.OrdersManagement
  alias BookingApi.Orders.Customer
  alias BookingApi.Orders.Order
  alias BookingApi.Stores.Store
  alias BookingApi.Payment.PaymentOrder
  alias BookingApi.Orders.ItemsClassification
  alias BookingApi.BussinessValidationError


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

    def add_a_item_classification() do
      %ItemsClassification{}
      |> ItemsClassification.changeset(%{name: "Bags Storage", value_to_store: 10.0})
      |> Repo.insert()
    end

    test "start a order" do
      {:ok, store} = create_store()

      # create a order
      assert {:ok, order} = OrdersManagement.start_order(store.id)
      assert order.status == "started"
      assert order.id != nil
    end

    test "should get the right item classification by name" do
      {:ok, item_classification} = add_a_item_classification()

      assert item_classification = OrdersManagement.get_item_classification_by_name(item_classification.name)
      assert item_classification.name == "Bags Storage"
      assert item_classification.value_to_store == Decimal.new("10.0")
    end

    test "fill a order with necessary data to process" do
      {:ok, store} = create_store()
      {:ok, order} = OrdersManagement.start_order(store.id)
      {:ok, item_classification} = add_a_item_classification()

      item = %{name: item_classification.name, quantity: 2}
      customer = %{name: "John Doe", email: "fabricioms.dev@gmail.com", phone: "123456789"}

      assert order = OrdersManagement.process_order(order.id, store.id, item, customer)
    end

    test "should return a error to a invalid order id" do
      assert_raise BussinessValidationError, "Order not found", fn ->
        OrdersManagement.process_order(
          "b7e08df4-97fc-4f1a-8bf6-fb0144160382",
          "b7e08df4-97fc-4f1a-8bf6-fb0144160382",
          %{name: "123", quantity: 2},
          %{name: "John Doe", email: "fabricioms.dev#gmail.com", phone: "123456789"}
        )
      end
    end

    #test -> should return exception with "store not found" if not found a store
    test "should return exception with 'store not found' on use get_store_by_id" do
      assert_raise BussinessValidationError, "Store not found", fn ->
        OrdersManagement.get_store_by_id("b7e08df4-97fc-4f1a-8bf6-fb0144160382")
      end
    end

    test "should return exception with 'store not found' if not found a store" do
      assert_raise BussinessValidationError, "Store not found", fn ->
        OrdersManagement.start_order("b7e08df4-97fc-4f1a-8bf6-fb0144160382")
      end
    end

    #test -> should return exception with "item classification not found" if not found a item classification
    test "should return exception with 'item classification not found' if not found a item classification" do
      {:ok, store} = create_store()
      {:ok, order} = OrdersManagement.start_order(store.id)

      item = %{name: "123", quantity: 2}
      customer = %{name: "John Doe", email: "fabricioms.dev@gmail.com", phone: "123456789"}

      assert_raise BussinessValidationError, "Classification of Item to store not found", fn ->
        OrdersManagement.process_order(order.id, store.id, item, customer)
      end
    end

    #test -> if dont have right customer data (email, name, phone) should return exception with "customer data is invalid"
    test "if dont have right customer data (email, name, phone) should return exception with 'customer data is invalid'" do
      {:ok, store} = create_store()
      {:ok, order} = OrdersManagement.start_order(store.id)
      {:ok, item_classification} = add_a_item_classification()

      item = %{name: item_classification.name, quantity: 2}
      customer = %{name: nil, email: nil, phone: nil}

      assert_raise MatchError, fn ->
        OrdersManagement.process_order(order.id, store.id, item, customer)
      end
    end
  end
end
