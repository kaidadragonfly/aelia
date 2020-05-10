defmodule Aelia.Artists do
  @moduledoc """
  The Artists context.
  """

  import Ecto.Query, warn: false
  alias Aelia.Repo

  alias Aelia.Artists.Artist

  @doc """
  Returns the list of artists.

  ## Examples

  iex> list_artists()
  [%Artist{}, ...]

  """
  defp list_artists do
    Repo.all(Artist)
  end

  @doc """
  Gets a single artist.

  Raises `Ecto.NoResultsError` if the Artist does not exist.

  ## Examples

  iex> get_artist!(123)
  %Artist{}
  """
  def get_artist_by_username(username) do
    Repo.get_by(Artist, username: username)
  end

  @doc """
  Creates a artist.

  ## Examples

  iex> create_artist(%{field: value})
  {:ok, %Artist{}}

  iex> create_artist(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_artist(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a artist.

  ## Examples

  iex> update_artist(artist, %{field: new_value})
  {:ok, %Artist{}}

  iex> update_artist(artist, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  defp update_artist(%Artist{} = artist, attrs) do
    artist
    |> Artist.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a artist.

  ## Examples

  iex> delete_artist(artist)
  {:ok, %Artist{}}

  iex> delete_artist(artist)
  {:error, %Ecto.Changeset{}}

  """
  defp delete_artist(%Artist{} = artist) do
    Repo.delete(artist)
  end
end
