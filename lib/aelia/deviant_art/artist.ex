defmodule Aelia.DeviantArt.Artist do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  schema "artists" do
    field :name, :string
    field :username, :string
    field :profile_url, :string
    field :icon_url, :string

    timestamps()
  end

  @doc false
  def changeset(artist, attrs) do
    artist
    |> cast(attrs, [:username, :id, :profile_url, :name, :icon_url])
    |> validate_required([:username, :id, :profile_url])
  end
end
