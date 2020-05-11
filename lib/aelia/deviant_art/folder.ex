defmodule Aelia.DeviantArt.Folder do
  use Ecto.Schema
  import Ecto.Changeset

  alias Aelia.DeviantArt.Artist

  @primary_key {:id, :string, []}
  @foreign_key_type :string

  schema "folders" do
    belongs_to :artist, Artist
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(folder, attrs) do
    folder
    |> cast(attrs, [:id, :name])
    |> validate_required([:id, :name])
  end
end
