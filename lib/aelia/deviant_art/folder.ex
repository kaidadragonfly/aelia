defmodule Aelia.DeviantArt.Folder do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  schema "folders" do
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
