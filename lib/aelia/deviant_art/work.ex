defmodule Aelia.DeviantArt.Work do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aelia.DeviantArt.Folder

  @primary_key {:id, :string, []}
  @foreign_key_type :string
  schema "works" do
    belongs_to :folder, Folder
    field :file_url, :string
    field :page_url, :string
    field :thumb_url, :string
    field :title, :string
    field :file, :binary
    field :file_type, :string
    field :thumb, :binary
    field :thumb_type, :string
    field :index, :integer

    timestamps()
  end

  @doc false
  def changeset(work, attrs) do
    work
    |> cast(attrs, [:id, :title, :page_url, :file_url, :thumb_url, :folder_id, :index])
    |> validate_required([:id, :title, :page_url, :file_url, :folder_id, :index])
  end
end
