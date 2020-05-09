defmodule AeliaWeb.ArtistController do
  use AeliaWeb, :controller

  alias Aelia.DeviantArt
  alias Aelia.DeviantArt.Api

  def create(conn, %{"artist" => %{"name" => username}}) do
    {:ok, artist_params} = Api.artist_info(username)

    case DeviantArt.create_or_update_artist(artist_params) do
      {:ok, artist} ->
        conn
        |> put_flash(:info, "Artist saved successfully.")
        |> redirect(to: Routes.artist_path(conn, :show, artist))
      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(artist_params)
        IO.inspect(changeset)

        conn
        |> put_flash(:info, "Failed to create artist!")
        |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id}) do
    artist = DeviantArt.get_artist!(id)
    render(conn, "show.html", artist: artist)
  end
end
