defmodule HarezmWeb.Router do
  use HarezmWeb, :router
  use AshAuthentication.Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HarezmWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :browser
    plug :require_authenticated
    plug :ensure_admin
  end

  scope "/", HarezmWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/contact", ContactController, :show
  end

  scope "/auth", HarezmWeb do
    pipe_through :browser

    forward "/", AshAuthentication.Phoenix.Router,
      register: true,
      reset_password: true
  end

  scope "/admin", HarezmWeb do
    pipe_through :admin

    live "/", AdminLive.Dashboard
    live "/users", AdminLive.Users
    live "/services", AdminLive.Services
    live "/messages", AdminLive.Messages
  end

  # Other scopes may use custom stacks.
  # scope "/api", HarezmWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:harezm, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HarezmWeb.Telemetry
    end
  end

  defp ensure_admin(conn, _opts) do
    case conn.assigns.current_user do
      %{role: :admin} -> conn
      _ -> conn |> redirect(to: "/") |> halt()
    end
  end
end
