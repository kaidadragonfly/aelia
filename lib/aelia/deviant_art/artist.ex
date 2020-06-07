defmodule Aelia.DeviantArt.Artist do
  use Ecto.Schema

  alias Aelia.DeviantArt.Folder

  @primary_key {:id, :string, []}
  schema "artists" do
    field :name, :string
    field :username, :string
    field :profile_url, :string
    field :icon_url, :string
    has_many :folders, Folder

    timestamps()
  end
end
