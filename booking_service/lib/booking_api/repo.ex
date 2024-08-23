defmodule BookingApi.Repo do
  use Ecto.Repo,
    otp_app: :booking_api,
    adapter: Ecto.Adapters.Postgres
end
