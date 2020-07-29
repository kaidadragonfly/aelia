defmodule AeliaWeb.FolderControllerTest do
  use AeliaWeb.ConnCase, async: true
  use ExUnitProperties

  alias Aelia.Repo
  alias Aelia.DeviantArt.{Artist, Folder, Work}

  setup_all do
    Application.put_env(:aelia, :da_base_url, "http://localhost:54200")
    Application.put_env(:aelia, :da_auth_url, "http://localhost:54200/auth")
  end

  describe "show" do
    test "can show an empty folder", %{conn: conn} do
      username = "Elyne"

      Repo.insert!(%Artist{
        id: "artist-id",
        username: username,
        profile_url: "artist-profile"
      })

      Repo.insert!(%Folder{
        id: "empty-folder-id",
        name: "Empty Folder",
        artist_id: "artist-id",
        parent_id: nil,
        index: 0
      })

      conn = get(conn, Routes.artist_folder_path(conn, :show, username, 0))

      assert html_response(conn, 200) =~ username
      # No works created.
      assert length(Repo.all(Work)) == 0
    end

    test "can show a folder with works", %{conn: conn} do
      username = "Elyne"

      Repo.insert!(%Artist{
        id: "artist-id",
        username: username,
        profile_url: "artist-profile"
      })

      Repo.insert!(%Folder{
        id: "work-folder-id",
        name: "Empty Folder",
        artist_id: "artist-id",
        parent_id: nil,
        index: 0
      })

      conn = get(conn, Routes.artist_folder_path(conn, :show, username, 0))

      assert html_response(conn, 200) =~ username
      # No works created.
      assert length(Repo.all(Work)) == 0
    end
  end
end
