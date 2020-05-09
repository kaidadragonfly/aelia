defmodule Aelia.Repo.Migrations.RenameNameInArtists do
  use Ecto.Migration

  def change do
    rename table("artists"), :name, to: :username
  end
end
