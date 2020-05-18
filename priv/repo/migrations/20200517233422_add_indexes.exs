defmodule Aelia.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create index("folders", [:artist_id, :index], unique: true)
    create index("works", [:folder_id, :index], unique: true)

    alter table("folders") do
      modify :artist_id, references("artists", type: :string)
    end

    alter table("works") do
      modify :folder_id, references("folders", type: :string)
    end
  end
end
