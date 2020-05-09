defmodule Aelia.Repo.Migrations.AddColumnsToArtists do
  use Ecto.Migration

  def change do
    alter table("artists") do
      add :name, :string
      add :profile_url, :string
      add :icon_url, :string
    end
  end
end
