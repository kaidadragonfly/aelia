defmodule Aelia.Repo.Migrations.RenameTypeToExtInWorks do
  use Ecto.Migration

  def change do
    rename table("works"), :file_type, to: :file_ext
    rename table("works"), :thumb_type, to: :thumb_ext
  end
end
