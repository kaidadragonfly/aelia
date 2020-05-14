defmodule Aelia.Repo.Migrations.AddImageThumbnailToWorks do
  use Ecto.Migration

  def change do
    alter table("works") do
      add :file, :bytea
      add :file_type, :string
      add :thumb, :bytea
      add :thumb_type, :string
    end
  end
end
