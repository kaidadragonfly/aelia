defmodule Aelia.Repo.Migrations.AddIndexToFolders do
  use Ecto.Migration

  def change do
    alter table("folders") do
      add :index, :integer
    end
  end
end
