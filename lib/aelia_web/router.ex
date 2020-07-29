defmodule AeliaWeb.Router do
  use AeliaWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/", AeliaWeb do
    pipe_through(:browser)

    get("/", PageController, :index)

    resources "/artists", ArtistController, param: "username", only: [:index, :show, :create] do
      resources "/folders", FolderController, param: "index", only: [:show] do
        resources("/works", WorkController, param: "index", only: [:show])
      end
    end

    get("/works/:id/thumb.:ext", WorkController, :thumb, as: "work_thumb")
    get("/works/:id/file.:ext", WorkController, :file, as: "work_file")
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router

  #   scope "/" do
  #     pipe_through :browser
  #     live_dashboard "/dashboard", metrics: AeliaWeb.Telemetry
  #   end
  # end
end
