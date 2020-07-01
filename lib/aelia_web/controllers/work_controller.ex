defmodule AeliaWeb.WorkController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt.Work
  alias Aelia.Repo

  def file(conn, %{"id" => id, "ext" => ext}) do
    work = Repo.get!(Work, id)

    send_download(
      conn,
      {:binary, work.file},
      disposition: :inline,
      filename: "#{id}.#{ext}"
    )
  end

  def thumb(conn, %{"id" => id, "ext" => ext}) do
    work = Repo.get!(Work, id)

    send_download(
      conn,
      {:binary, work.thumb},
      disposition: :inline,
      filename: "#{id}-thumb.#{ext}"
    )
  end

  def show(
        conn,
        %{
          "artist_username" => username,
          "folder_index" => folder_index,
          "index" => index
        }
      ) do
    render(conn, "show.html",
      work: Work.get!(%{username: username, folder_index: folder_index, index: index})
    )
  end
end
