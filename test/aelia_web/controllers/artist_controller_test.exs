defmodule AeliaWeb.ArtistControllerTest do
  use AeliaWeb.ConnCase, async: true
  use ExUnitProperties

  # def fixture(:artist) do
  #   {:ok, artist} = DeviantArt.create_artist(@create_attrs)
  #   artist
  # end

  describe "index" do
    test "lists all artists", %{conn: conn} do
      conn = get(conn, Routes.artist_path(conn, :index))

      assert redirected_to(conn) == "/"
    end
  end

  describe "create" do
    test "redirects to the proper artist", %{conn: conn} do
      check all username <- StreamData.string(:alphanumeric, min_length: 6) do
        conn = post(
          conn,
          Routes.artist_path(conn, :create, username: username))

        assert redirected_to(conn) == "/artists/#{username}"
      end
    end
  end

  describe "show" do
    test "creates a new valid artist", %{conn: conn} do
      conn = get(conn, Routes.artist_path(conn, :show, "valid-new"))
    end

    test "returns info for an artist that already exists" do
    end

    test "returns 404 for an artist that doesn't exist" do
    end
  end
end
