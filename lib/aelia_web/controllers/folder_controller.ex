defmodule AeliaWeb.FolderController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt

  def show(conn, %{"username" => username, "index" => index}) do
    {:ok, folder} = DeviantArt.folder(username, index)

    render(conn, "show.html", folder: folder)
  end
end
