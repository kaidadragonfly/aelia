defmodule AeliaWeb.ArtistController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt
  alias Aelia.Artists

  def show(conn, %{"username" => username}) do
    case DeviantArt.artist_info(username) do
      {:ok, artist} ->
        conn
        |> put_flash(:info, "Artist saved successfully.")
        |> render("show.html", artist: artist)
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Failed save artist #{username}!")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  defp process_artist(conn, {:error, error}) do
    IO.inspect(error)

    conn
    |> put_flash(:info, error)
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
