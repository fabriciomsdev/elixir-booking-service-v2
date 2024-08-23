defmodule BookingServiceWeb.Router do
  use BookingServiceWeb, :router

  pipeline :api do
    plug Corsica,
      origins: "*",
      allow_headers: ~w(content-type authorization accept origin),
      allow_methods: ~w(GET POST PUT DELETE OPTIONS),
      max_age: 0,
      allow_credentials: false
    plug :accepts, ["json"]
  end

  scope "/api", BookingServiceWeb do
    pipe_through :api

    post "/orders", OrdersController, :new
    put "/orders/:id", OrdersController, :update
    delete "/orders/:id", OrdersController, :delete
    get "/orders/:id", OrdersController, :find

    get "/classifications", ItemsClassificationController, :list
    match :options, "/*path", BookingServiceWeb.CORSController, :options
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:booking_service, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BookingServiceWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
