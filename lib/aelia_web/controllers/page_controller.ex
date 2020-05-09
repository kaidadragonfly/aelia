defmodule AeliaWeb.PageController do
  use AeliaWeb, :controller

  def search(conn, %{"user" => %{"name" => username}}) do
    {:ok, folders} = Aelia.DeviantArt.folders(username)

    render(conn, "search.html", folders: folders)
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
