defmodule AeliaWeb.Router do
  use AeliaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AeliaWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/works/:id/thumb", WorkController, :thumb, as: "work_thumb"
    get "/works/:id/file", WorkController, :file, as: "work_file"
  end

  scope "/artists", AeliaWeb do
    pipe_through :browser

    post "/", ArtistController, :search, as: "artists_search"
    get "/", ArtistController, :index, as: "artists"
    get "/:username", ArtistController, :show, as: "artist"
    get "/:username/folders/:index", FolderController, :show, as: "folder"
    get "/:username/folders/:folder_index/works/:index", WorkController, :show, as: "work"
  end


  # Other scopes may use custom stacks.
  # scope "/api", AeliaWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: AeliaWeb.Telemetry
    end
  end
end
