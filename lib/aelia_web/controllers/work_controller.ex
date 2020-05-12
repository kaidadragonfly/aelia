defmodule AeliaWeb.WorkController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt
  alias Aelia.DeviantArt.Work
  alias Aelia.Repo

  def show(conn, %{"id" => id}) do
    work = Repo.get!(Work, id)
    render(conn, "show.html", work: work)
  end
end
