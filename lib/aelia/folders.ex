defmodule Aelia.Folders do
  @moduledoc """
  The Folders context.
  """

  import Ecto.Query, warn: false
  alias Aelia.Repo

  alias Aelia.Folders.Folder

  @doc """
  Returns the list of folders.

  ## Examples

  iex> list_folders()
  [%Folder{}, ...]

  """
  defp list_folders do
    Repo.all(Folder)
  end

  @doc """
  Creates a folder if it doesn't exist, updates it otherwise.

  Checks for existence based on :id.

  ## Examples

  iex> create_or_update_folder(%{field: value})
  {:ok, %Folder{}}

  iex> create_or_update_folder(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_or_update_folder(attrs \\ %{}) do
    case Repo.get(Folder, attrs.id) do
      nil -> create_folder(attrs)
      folder -> update_folder(folder, attrs)
    end
  end

  @doc """
  Creates a folder.

  ## Examples

  iex> create_folder(%{field: value})
  {:ok, %Folder{}}

  iex> create_folder(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  defp create_folder(attrs \\ %{}) do
    %Folder{}
    |> Folder.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a folder.

  ## Examples

  iex> update_folder(folder, %{field: new_value})
  {:ok, %Folder{}}

  iex> update_folder(folder, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  defp update_folder(%Folder{} = folder, attrs) do
    folder
    |> Folder.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a folder.

  ## Examples

  iex> delete_folder(folder)
  {:ok, %Folder{}}

  iex> delete_folder(folder)
  {:error, %Ecto.Changeset{}}

  """
  def delete_folder(%Folder{} = folder) do
    Repo.delete(folder)
  end
end
