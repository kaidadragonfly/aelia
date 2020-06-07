defmodule Aelia.DeviantArt.Folder do
  use Ecto.Schema

  alias Aelia.DeviantArt.{Artist, Folder, Work}

  @primary_key {:id, :string, []}
  @foreign_key_type :string
  schema "folders" do
    belongs_to :artist, Artist
    field :name, :string
    field :parent_id, :string
    field :index, :integer
    has_many :works, Work
    belongs_to :parent, Folder, foreign_key: :parent_id, references: :id, define_field: false
    has_many :children, Folder, foreign_key: :parent_id, references: :id

    timestamps()
  end
end
