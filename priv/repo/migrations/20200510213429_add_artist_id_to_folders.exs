defmodule Aelia.Repo.Migrations.AddArtistIdToFolders do
  use Ecto.Migration

  def change do
    create unique_index("artists", [:id])

    alter table("folders") do
      add :artist_id, :string, [references(:artists)]
    end
  end
end
