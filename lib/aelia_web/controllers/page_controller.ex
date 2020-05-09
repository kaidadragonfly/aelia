defmodule AeliaWeb.PageController do
  use AeliaWeb, :controller
  alias Aelia.DeviantArt.Api

  def search(conn, %{"user" => %{"name" => username}}) do
    {:ok, folders} = Api.folders(username)

    render(conn, "search.html", folders: folders)
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
