defmodule BookingApi.OrdersTest do
  use BookingApi.DataCase
  alias BookingApi.Orders
  alias BookingApi.OrdersManagement
  alias BookingApi.Orders.Customer
  alias BookingApi.Stores.Store
  alias BookingApi.Orders.ItemsClassification
  alias BookingApi.BussinessValidationError
  alias BookingApi.Orders.OrderItem
  use ExUnit.Case, async: true

  describe "orders management" do
    alias BookingApi.OrdersManagement

    import BookingApi.OrdersFixtures

    @invalid_attrs %{error: nil, status: nil, total_value: nil, quantity: nil}

    def get_fake_payment_data() do
      %{
        credit_card: "1312 1234 5423 6423",
        cvv: "123",
        expiration_date: "12/2028"
      }
    end

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

    def get_test_customer_data() do
      %{
        name: "John Doe",
        email: "fabricioms.dev@gmail.com",
        phone: "123456789"
      }
    end

    def get_test_order_items_data() do
      [
        %{
          name: "Bags Storage",
          quantity: 2
        }
      ]
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

      payment_data = get_fake_payment_data()
      items = get_test_order_items_data()
      customer = get_test_customer_data()

      assert order = OrdersManagement.process_order(order.id, store.id, items, customer, payment_data)
    end

    test "should return a error to a invalid order id" do
      assert_raise BussinessValidationError, "Order not found", fn ->
        OrdersManagement.process_order(
          "b7e08df4-97fc-4f1a-8bf6-fb0144160382",
          "b7e08df4-97fc-4f1a-8bf6-fb0144160382",
          get_test_order_items_data(),
          get_test_customer_data(),
          get_fake_payment_data()
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

      items = [
        %{
          name: "--",
          quantity: 2
        }
      ]
      customer = get_test_customer_data()

      assert_raise BussinessValidationError, "Classification of Item to store not found", fn ->
        OrdersManagement.process_order(order.id, store.id, items, customer, get_fake_payment_data())
      end
    end

    #test -> if dont have right customer data (email, name, phone) should return exception with "customer data is invalid"
    test "if dont have right customer data (email, name, phone) should return exception with 'customer data is invalid'" do
      {:ok, store} = create_store()
      {:ok, order} = OrdersManagement.start_order(store.id)

      items = get_test_order_items_data()
      customer = %{name: nil, email: nil, phone: nil}
      payment = get_fake_payment_data()

      assert_raise MatchError, fn ->
        OrdersManagement.process_order(order.id, store.id, items, customer, payment)
      end
    end

    test "should can move a order to paid status" do
      {:ok, store} = create_store()
      {:ok, order} = OrdersManagement.start_order(store.id)

      payment_data = get_fake_payment_data()
      items = get_test_order_items_data()
      customer = get_test_customer_data()

      {:ok, order} = OrdersManagement.process_order(order.id, store.id, items, customer, payment_data)
      OrdersManagement.set_order_as_paid(order)

      assert order = OrdersManagement.get_order(order.id)
      assert order.status == "paid"
    end

    # test -> should can move a order to booked status
    test "should can move a order to booked status" do
      {:ok, store} = create_store()
      {:ok, order} = OrdersManagement.start_order(store.id)

      payment_data = get_fake_payment_data()
      items = get_test_order_items_data()
      customer = get_test_customer_data()

      {:ok, order} = OrdersManagement.process_order(order.id, store.id, items, customer, payment_data)

      OrdersManagement.set_order_as_paid(order)
      OrdersManagement.book_order(order)

      assert order = OrdersManagement.get_order(order.id)
      assert order.status == "booked"
    end
  end

  describe "orders_items" do
    alias BookingApi.Orders.OrderItem

    import BookingApi.OrdersFixtures

    @invalid_attrs %{total_value: nil, quantity: nil}

    test "list_orders_items/0 returns all orders_items" do
      order_item = order_item_fixture()
      assert Orders.list_orders_items() == [order_item]
    end

    test "get_order_item!/1 returns the order_item with given id" do
      order_item = order_item_fixture()
      assert Orders.get_order_item!(order_item.id) == order_item
    end

    test "create_order_item/1 with valid data creates a order_item" do
      valid_attrs = %{total_value: "120.5", quantity: 42}

      assert {:ok, %OrderItem{} = order_item} = Orders.create_order_item(valid_attrs)
      assert order_item.total_value == Decimal.new("120.5")
      assert order_item.quantity == 42
    end

    test "create_order_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order_item(@invalid_attrs)
    end

    test "update_order_item/2 with valid data updates the order_item" do
      order_item = order_item_fixture()
      update_attrs = %{total_value: "456.7", quantity: 43}

      assert {:ok, %OrderItem{} = order_item} = Orders.update_order_item(order_item, update_attrs)
      assert order_item.total_value == Decimal.new("456.7")
      assert order_item.quantity == 43
    end

    test "update_order_item/2 with invalid data returns error changeset" do
      order_item = order_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order_item(order_item, @invalid_attrs)
      assert order_item == Orders.get_order_item!(order_item.id)
    end

    test "delete_order_item/1 deletes the order_item" do
      order_item = order_item_fixture()
      assert {:ok, %OrderItem{}} = Orders.delete_order_item(order_item)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order_item!(order_item.id) end
    end

    test "change_order_item/1 returns a order_item changeset" do
      order_item = order_item_fixture()
      assert %Ecto.Changeset{} = Orders.change_order_item(order_item)
    end
  end
end
