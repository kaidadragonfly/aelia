defmodule AeliaWeb.PageController do
  use AeliaWeb, :controller

  def index(conn, _params) do
    username = "team"
    {:ok, folders} = Aelia.DeviantArt.folders(username)

    IO.inspect(Enum.at(folders, 2).())

    render(conn, "index.html")
  end
end
