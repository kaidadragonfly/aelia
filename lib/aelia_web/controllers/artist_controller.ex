defmodule AeliaWeb.ArtistController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt
  alias Aelia.DeviantArt.Api

  def show(conn, %{"username" => username}) do
    conn |> process_artist(Api.artist_info(username))
  end

  defp process_artist(conn, {:ok, artist_params}) do
    case DeviantArt.create_or_update_artist(artist_params) do
      {:ok, artist} ->
        conn
        |> put_flash(:info, "Artist saved successfully.")
        |> render("show.html", artist: artist)
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(artist_params)
        IO.inspect(changeset)

        conn
        |> put_flash(:info, "Failed to save artist!")
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
