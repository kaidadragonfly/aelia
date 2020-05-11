defmodule AeliaWeb.FolderController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt
  alias Aelia.DeviantArt.Folder

  def show(conn, %{"id" => id}) do
    {:ok, folder} = DeviantArt.folder(id)
    IO.inspect(folder)
    render(conn, "show.html", folder: folder)
  end
end
