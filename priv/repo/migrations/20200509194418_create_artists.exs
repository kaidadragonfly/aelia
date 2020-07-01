defmodule Aelia.Repo.Migrations.CreateArtists do
  use Ecto.Migration

  def change do
    create table(:artists, primary_key: false) do
      add :name, :string, primary_key: true
      add :id, :string

      timestamps()
    end
  end
end
