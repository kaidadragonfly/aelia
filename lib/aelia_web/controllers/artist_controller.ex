defmodule AeliaWeb.ArtistController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt

  def index(conn, _params) do
    redirect(conn, to: Routes.page_path(conn, :index))
  end

  def search(conn, %{"username" => username}) do
    # TODO: Handle not_found here. Display a search box.
    redirect(conn, to: Routes.artist_path(conn, :show, username))
  end

  def show(conn, %{"username" => username}) do
    case DeviantArt.artist_info(username) do
      {:ok, artist} ->
        conn
        |> put_flash(:info, "Artist saved successfully.")
        |> render("show.html", artist: artist)
      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:info, "Failed save artist #{username}!")
        |> redirect(to: Routes.page_path(conn, :index))
      {:error, message} ->
        conn
        |> put_flash(:info, message)
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end
end
