defmodule AeliaWeb.PageController do
  use AeliaWeb, :controller

  def index(conn, _params) do
    {:ok, folders} = Aelia.DeviantArt.folders("team")

    render(conn, "index.html", folders: folders)
  end
end
