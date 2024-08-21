defmodule BookingApi.StoresFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `BookingApi.Stores` context.
  """

  @doc """
  Generate a store.
  """
  def store_fixture(attrs \\ %{}) do
    {:ok, store} =
      attrs
      |> Enum.into(%{
        address: "some address",
        name: "some name"
      })
      |> BookingApi.Stores.create_store()

    store
  end
end
