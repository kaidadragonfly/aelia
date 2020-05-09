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
end
