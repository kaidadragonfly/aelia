defmodule Aelia.DeviantArtTest do
  use Aelia.DataCase

  alias Aelia.DeviantArt

  describe "artists" do
    alias Aelia.DeviantArt.Artist

    @valid_attrs %{id: "some id", name: "some name"}
    @update_attrs %{id: "some updated id", name: "some updated name"}
    @invalid_attrs %{id: nil, name: nil}

    def artist_fixture(attrs \\ %{}) do
      {:ok, artist} =
        attrs
        |> Enum.into(@valid_attrs)
        |> DeviantArt.create_artist()

      artist
    end

    test "list_artists/0 returns all artists" do
      artist = artist_fixture()
      assert DeviantArt.list_artists() == [artist]
    end

    test "get_artist!/1 returns the artist with given id" do
      artist = artist_fixture()
      assert DeviantArt.get_artist!(artist.id) == artist
    end

    test "create_artist/1 with valid data creates a artist" do
      assert {:ok, %Artist{} = artist} = DeviantArt.create_artist(@valid_attrs)
      assert artist.id == "some id"
      assert artist.name == "some name"
    end

    test "create_artist/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DeviantArt.create_artist(@invalid_attrs)
    end

    test "update_artist/2 with valid data updates the artist" do
      artist = artist_fixture()
      assert {:ok, %Artist{} = artist} = DeviantArt.update_artist(artist, @update_attrs)
      assert artist.id == "some updated id"
      assert artist.name == "some updated name"
    end

    test "update_artist/2 with invalid data returns error changeset" do
      artist = artist_fixture()
      assert {:error, %Ecto.Changeset{}} = DeviantArt.update_artist(artist, @invalid_attrs)
      assert artist == DeviantArt.get_artist!(artist.id)
    end

    test "delete_artist/1 deletes the artist" do
      artist = artist_fixture()
      assert {:ok, %Artist{}} = DeviantArt.delete_artist(artist)
      assert_raise Ecto.NoResultsError, fn -> DeviantArt.get_artist!(artist.id) end
    end

    test "change_artist/1 returns a artist changeset" do
      artist = artist_fixture()
      assert %Ecto.Changeset{} = DeviantArt.change_artist(artist)
    end
  end

  describe "folders" do
    alias Aelia.DeviantArt.Folder

    @valid_attrs %{id: "some id", name: "some name"}
    @update_attrs %{id: "some updated id", name: "some updated name"}
    @invalid_attrs %{id: nil, name: nil}

    def folder_fixture(attrs \\ %{}) do
      {:ok, folder} =
        attrs
        |> Enum.into(@valid_attrs)
        |> DeviantArt.create_folder()

      folder
    end

    test "list_folders/0 returns all folders" do
      folder = folder_fixture()
      assert DeviantArt.list_folders() == [folder]
    end

    test "get_folder!/1 returns the folder with given id" do
      folder = folder_fixture()
      assert DeviantArt.get_folder!(folder.id) == folder
    end

    test "create_folder/1 with valid data creates a folder" do
      assert {:ok, %Folder{} = folder} = DeviantArt.create_folder(@valid_attrs)
      assert folder.id == "some id"
      assert folder.name == "some name"
    end

    test "create_folder/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = DeviantArt.create_folder(@invalid_attrs)
    end

    test "update_folder/2 with valid data updates the folder" do
      folder = folder_fixture()
      assert {:ok, %Folder{} = folder} = DeviantArt.update_folder(folder, @update_attrs)
      assert folder.id == "some updated id"
      assert folder.name == "some updated name"
    end

    test "update_folder/2 with invalid data returns error changeset" do
      folder = folder_fixture()
      assert {:error, %Ecto.Changeset{}} = DeviantArt.update_folder(folder, @invalid_attrs)
      assert folder == DeviantArt.get_folder!(folder.id)
    end

    test "delete_folder/1 deletes the folder" do
      folder = folder_fixture()
      assert {:ok, %Folder{}} = DeviantArt.delete_folder(folder)
      assert_raise Ecto.NoResultsError, fn -> DeviantArt.get_folder!(folder.id) end
    end

    test "change_folder/1 returns a folder changeset" do
      folder = folder_fixture()
      assert %Ecto.Changeset{} = DeviantArt.change_folder(folder)
    end
  end
end
