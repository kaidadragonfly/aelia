defmodule AeliaWeb.ArtistControllerTest do
  use AeliaWeb.ConnCase

  alias Aelia.DeviantArt

  @create_attrs %{id: "some id", name: "some name"}
  @update_attrs %{id: "some updated id", name: "some updated name"}
  @invalid_attrs %{id: nil, name: nil}

  def fixture(:artist) do
    {:ok, artist} = DeviantArt.create_artist(@create_attrs)
    artist
  end

  describe "index" do
    test "lists all artists", %{conn: conn} do
      conn = get(conn, Routes.artist_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Artists"
    end
  end

  describe "new artist" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.artist_path(conn, :new))
      assert html_response(conn, 200) =~ "New Artist"
    end
  end

  describe "create artist" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.artist_path(conn, :create), artist: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.artist_path(conn, :show, id)

      conn = get(conn, Routes.artist_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Artist"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.artist_path(conn, :create), artist: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Artist"
    end
  end

  describe "edit artist" do
    setup [:create_artist]

    test "renders form for editing chosen artist", %{conn: conn, artist: artist} do
      conn = get(conn, Routes.artist_path(conn, :edit, artist))
      assert html_response(conn, 200) =~ "Edit Artist"
    end
  end

  describe "update artist" do
    setup [:create_artist]

    test "redirects when data is valid", %{conn: conn, artist: artist} do
      conn = put(conn, Routes.artist_path(conn, :update, artist), artist: @update_attrs)
      assert redirected_to(conn) == Routes.artist_path(conn, :show, artist)

      conn = get(conn, Routes.artist_path(conn, :show, artist))
      assert html_response(conn, 200) =~ "some updated id"
    end

    test "renders errors when data is invalid", %{conn: conn, artist: artist} do
      conn = put(conn, Routes.artist_path(conn, :update, artist), artist: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Artist"
    end
  end

  describe "delete artist" do
    setup [:create_artist]

    test "deletes chosen artist", %{conn: conn, artist: artist} do
      conn = delete(conn, Routes.artist_path(conn, :delete, artist))
      assert redirected_to(conn) == Routes.artist_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.artist_path(conn, :show, artist))
      end
    end
  end

  defp create_artist(_) do
    artist = fixture(:artist)
    %{artist: artist}
  end
end
