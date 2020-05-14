defmodule AeliaWeb.WorkController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt
  alias Aelia.DeviantArt.Work
  alias Aelia.Repo

  def file(conn, %{"id" => id}) do
    work = Repo.get!(Work, id)

    send_download(conn, {:binary, work.file}, disposition: :inline)
  end

  def thumb(conn, %{"id" => id}) do
    work = Repo.get!(Work, id)

    send_download(conn, {:binary, work.thumb}, disposition: :inline)
  end

  def show(conn, %{"id" => id}) do
    work = Repo.get!(Work, id)
    render(conn, "show.html", work: work)
  end
end
