defmodule AeliaWeb.ArtistControllerTest do
  use AeliaWeb.ConnCase, async: true
  use ExUnitProperties

  alias Aelia.Repo
  alias Aelia.DeviantArt.{Artist, Folder}

  # def fixture(:artist) do
  #   {:ok, artist} = DeviantArt.create_artist(@create_attrs)
  #   artist
  # end

  setup_all do
    Application.put_env(:aelia, :da_base_url, "http://localhost:54200")
    Application.put_env(:aelia, :da_auth_url, "http://localhost:54200/auth")
  end

  describe "index" do
    test "lists all artists", %{conn: conn} do
      conn = get(conn, Routes.artist_path(conn, :index))

      assert redirected_to(conn) == Routes.page_path(conn, :index)
    end
  end

  describe "create" do
    test "redirects to the proper artist", %{conn: conn} do
      check all username <- StreamData.string(:alphanumeric, min_length: 6) do
        conn = post(
          conn,
          Routes.artist_path(conn, :create, username: username))

        assert redirected_to(conn) == Routes.artist_path(conn, :show, username)
      end
    end
  end

  describe "show" do
    test "creates an artist with only featured folder", %{conn: conn} do
      check all suffix <- StreamData.string(:alphanumeric, min_length: 6) do
        Repo.delete_all(Artist)

        username = "featured-#{suffix}"
        conn = get(conn, Routes.artist_path(conn, :show, username))

        assert html_response(conn, 200) =~ username

        artists = Repo.all(Artist)

        assert length(artists) == 1
        assert [artist] = artists
        assert artist.username == username

        folders = Repo.all(Folder)

        assert length(folders) == 1
        assert [folder] = folders
        assert folder.name == "Featured"
        assert Repo.preload(folder, :parent).parent == nil
      end
    end

    test "returns info for an artist that already exists" do
    end

    test "returns 404 for an artist that doesn't exist" do
    end
  end
end
