# TODO: It should be called StorePoint or StoragePoint instead of Store
defmodule BookingService.Stores.Store do
  @moduledoc """
  This module defines the Store schema and changeset functions.

  A Store represents a physical or online location where bookings can be made.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "stores" do
    field :name, :string
    field :address, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(store, attrs) do
    store
    |> cast(attrs, [:name, :address])
    |> validate_required([:name, :address])
  end
end
