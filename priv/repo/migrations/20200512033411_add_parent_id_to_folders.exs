defmodule Aelia.Repo.Migrations.AddParentIdToFolders do
  use Ecto.Migration

  def change do
    alter table("folders") do
      add :parent_id, :string
    end
  end
end
