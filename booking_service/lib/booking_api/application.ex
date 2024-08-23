defmodule BookingApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BookingApiWeb.Telemetry,
      BookingApi.Repo,
      {DNSCluster, query: Application.get_env(:booking_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BookingApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: BookingApi.Finch},
      # Start a worker by calling: BookingApi.Worker.start_link(arg)
      # {BookingApi.Worker, arg},
      # Start to serve requests, typically the last entry
      BookingApiWeb.Endpoint,
      BookingApi.PaymentsProcessorWorker,
      BookingApi.OrdersUpdateProcessorWorker
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BookingApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BookingApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
