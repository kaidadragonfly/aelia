defmodule AeliaWeb.WorkController do
  use AeliaWeb, :controller
  import Ecto.Query, only: [from: 2]

  alias Aelia.DeviantArt
  alias Aelia.DeviantArt.{Work, Folder, Artist}
  alias Aelia.Repo

  def file(conn, %{"id" => id}) do
    work = Repo.get!(Work, id)

    send_download(
      conn,
      {:binary, work.file},
      disposition: :inline,
      filename: "#{id}")
  end

  def thumb(conn, %{"id" => id}) do
    work = Repo.get!(Work, id)

    send_download(
      conn,
      {:binary, work.thumb},
      disposition: :inline,
      filename: "#{id}-thumb")
  end

  def show(conn, %{
        "username" => username,
        "folder_index" => folder_index,
        "index" => index}) do
    work = Repo.one(
      from w in Work,
      where: w.index == ^index,
      join: f in Folder,
      on: w.folder_id == f.id,
      where: f.index == ^folder_index,
      join: a in Artist,
      on: f.artist_id == a.id,
      where: a.username == ^username)

    render(conn, "show.html", work: work)
  end
end
