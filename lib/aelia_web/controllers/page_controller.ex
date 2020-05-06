defmodule AeliaWeb.PageController do
  import Aelia.DeviantArt
  use AeliaWeb, :controller

  def index(conn, _params) do
    folders = token_auth |> fetch_folders("team")
    IO.inspect(folders)

    render(conn, "index.html")
  end
end
