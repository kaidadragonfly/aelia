defmodule Aelia.Repo.Migrations.RequireFields do
  use Ecto.Migration

  def change do
    create index("artists", [:username], unique: true)

    alter table("folders") do
      modify :name, :string, null: false
      modify :artist_id, :string, null: false
      modify :index, :integer, null: false
    end

    alter table("works") do
      modify :title, :string, null: false
      modify :page_url, :string, null: false
      modify :folder_id, :string, null: false
      modify :index, :integer, null: false
    end
  end
end
