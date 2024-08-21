# defmodule BookingApi.StoresTest do
#   use BookingApi.DataCase

#   alias BookingApi.Stores

#   describe "stores" do
#     alias BookingApi.Stores.Store

#     import BookingApi.StoresFixtures

#     @invalid_attrs %{name: nil, address: nil}

#     test "list_stores/0 returns all stores" do
#       store = store_fixture()
#       assert Stores.list_stores() == [store]
#     end

#     test "get_store!/1 returns the store with given id" do
#       store = store_fixture()
#       assert Stores.get_store!(store.id) == store
#     end

#     test "create_store/1 with valid data creates a store" do
#       valid_attrs = %{name: "some name", address: "some address"}

#       assert {:ok, %Store{} = store} = Stores.create_store(valid_attrs)
#       assert store.name == "some name"
#       assert store.address == "some address"
#     end

#     test "create_store/1 with invalid data returns error changeset" do
#       assert {:error, %Ecto.Changeset{}} = Stores.create_store(@invalid_attrs)
#     end

#     test "update_store/2 with valid data updates the store" do
#       store = store_fixture()
#       update_attrs = %{name: "some updated name", address: "some updated address"}

#       assert {:ok, %Store{} = store} = Stores.update_store(store, update_attrs)
#       assert store.name == "some updated name"
#       assert store.address == "some updated address"
#     end

#     test "update_store/2 with invalid data returns error changeset" do
#       store = store_fixture()
#       assert {:error, %Ecto.Changeset{}} = Stores.update_store(store, @invalid_attrs)
#       assert store == Stores.get_store!(store.id)
#     end

#     test "delete_store/1 deletes the store" do
#       store = store_fixture()
#       assert {:ok, %Store{}} = Stores.delete_store(store)
#       assert_raise Ecto.NoResultsError, fn -> Stores.get_store!(store.id) end
#     end

#     test "change_store/1 returns a store changeset" do
#       store = store_fixture()
#       assert %Ecto.Changeset{} = Stores.change_store(store)
#     end
#   end
# end
