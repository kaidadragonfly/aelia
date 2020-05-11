defmodule Aelia.Repo.Migrations.AddIndexToWorks do
  use Ecto.Migration

  def change do
    alter table("works") do
      add :index, :int
    end
  end
end
