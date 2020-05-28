defmodule Aelia.DeviantArt.Work do
  use Ecto.Schema
  import Ecto.Query, only: [from: 2]

  alias Aelia.DeviantArt.{Artist, Folder, Work}
  alias Aelia.Repo

  @primary_key {:id, :string, []}
  @foreign_key_type :string
  schema "works" do
    belongs_to :folder, Folder
    field :file_url, :string
    field :page_url, :string
    field :thumb_url, :string
    field :title, :string
    field :file, :binary
    field :file_ext, :string
    field :thumb, :binary
    field :thumb_ext, :string
    field :index, :integer
    field :username, :string, virtual: true
    field :folder_index, :integer, virtual: true

    timestamps()
  end

  def get!(%{"username" => username,
             "folder_index" => folder_index,
             "index" => index}) do

    Repo.one!(
      from w in Work,
      where: w.index == ^index,
      join: f in Folder,
      on: w.folder_id == f.id,
      where: f.index == ^folder_index,
      join: a in Artist,
      on: f.artist_id == a.id,
      where: a.username == ^username,
      select_merge: %{username: ^username, folder_index: ^folder_index})
  end
end
