defmodule Aelia.Repo.Migrations.AddIndexOnArtistUsername do
  use Ecto.Migration

  def change do
    create index("artists", [:username])
  end
end
