defmodule Aelia.Repo.Migrations.CreateFolders do
  use Ecto.Migration

  def change do
    create table(:folders, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
