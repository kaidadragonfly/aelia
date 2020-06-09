defmodule AeliaWeb.ArtistControllerTest do
  use AeliaWeb.ConnCase, async: true
  use ExUnitProperties

  alias Aelia.Repo
  alias Aelia.DeviantArt.{Artist, Folder, Work}

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
    test "handles an artist with only featured folder", %{conn: conn} do
      username = "featured"
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

      # Works should be lazy loaded.
      assert length(Repo.all(Work)) == 0
    end

    test "\"Featured\" is not considered a parent", %{conn: conn} do
      username = "featured-multi"
      conn = get(conn, Routes.artist_path(conn, :show, username))

      assert html_response(conn, 200) =~ username

      artists = Repo.all(Artist)

      assert length(artists) == 1
      assert [artist] = artists
      assert artist.username == username

      folders = Repo.all(Folder)
      |> Enum.map(&(Repo.preload(&1, [:parent, :children])))
      assert length(folders) == 4

      assert [featured] = folders |> Enum.filter(&(&1.name == "Featured"))
      assert featured.name == "Featured"
      assert featured.parent == nil

      folders = folders |> Enum.reject(&(&1.name == "Featured"))

      assert length(folders) == 3
      folders |> Enum.each(fn folder ->
        assert folder.parent == nil
        assert length(folder.children) == 0
      end)

      # Works should be lazy loaded.
      assert length(Repo.all(Work)) == 0
    end

    test "handles nested folders properly", %{conn: conn} do
      username = "multi"
      conn = get(conn, Routes.artist_path(conn, :show, username))

      assert html_response(conn, 200) =~ username

      artists = Repo.all(Artist)

      assert length(artists) == 1
      assert [artist] = artists
      assert artist.username == username

      folders = Repo.all(Folder)
      |> Enum.map(&(Repo.preload(&1, [:parent, :children])))

      assert length(folders) == 6

      assert [featured] = folders |> Enum.filter(&(&1.name == "Featured"))
      assert featured.name == "Featured"
      assert featured.parent == nil

      folders = folders |> Enum.reject(&(&1.name == "Featured"))
      assert length(folders) == 5

      assert [parent] = folders |> Enum.filter(&(&1.name == "Parent"))
      assert length(parent.children) == 3
      assert parent.parent == nil

      folders = folders |> Enum.reject(&(&1.name == "Parent"))
      assert length(folders) == 4

      assert [single] = folders |> Enum.filter(&(&1.name == "Single"))
      assert length(single.children) == 0
      assert single.parent == nil

      folders = folders |> Enum.reject(&(&1.name == "Single"))
      assert length(folders) == 3

      folders |> Enum.each(fn folder ->
        assert folder.parent_id == parent.id
        assert length(folder.children) == 0
      end)

      # Works should be lazy loaded.
      assert length(Repo.all(Work)) == 0
    end

    test "handles an artist that already exists", %{conn: conn} do
      username = "existing"
      Repo.insert!(
        %Artist{
          id: "existingid",
          username: username,
          profile_url: "http://localhost:44200/profile/#{username}"})

      conn = get(conn, Routes.artist_path(conn, :show, username))

      assert html_response(conn, 200) =~ username

      # TODO: Add functionality to update the artist from upstream.
    end

    test "returns 404 for an artist that doesn't exist", %{conn: conn} do
      username = "missing"
      conn = get(conn, Routes.artist_path(conn, :show, username))

      assert html_response(conn, 302)
      assert get_flash(conn, :info) =~ username
    end
  end
end
