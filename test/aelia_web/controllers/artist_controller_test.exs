defmodule AeliaWeb.ArtistControllerTest do
  use AeliaWeb.ConnCase

  # @create_attrs %{id: "some id", name: "some name"}
  # @update_attrs %{id: "some updated id", name: "some updated name"}
  # @invalid_attrs %{id: nil, name: nil}

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
end
