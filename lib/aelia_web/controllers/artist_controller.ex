defmodule AeliaWeb.ArtistController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt

  def index(conn, _params) do
    # TODO: Display artists viewed by current user.
    redirect(conn, to: Routes.page_path(conn, :index))
  end

  def create(conn, %{"username" => username}) do
    # TODO: Handle not_found here. Display a search box.
    redirect(conn, to: Routes.artist_path(conn, :show, username))
  end

  def show(conn, %{"username" => username}) do
    case DeviantArt.artist_info(username) do
      {:ok, artist} ->
        conn
        |> put_flash(:info, "Artist saved successfully.")
        |> render("show.html", artist: artist)

      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
