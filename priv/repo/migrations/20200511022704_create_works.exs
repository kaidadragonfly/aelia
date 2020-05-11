defmodule Aelia.Repo.Migrations.CreateWorks do
  use Ecto.Migration

  def change do
    create table(:works, primary_key: false) do
      add :id, :string, primary_key: true
      add :title, :string
      add :page_url, :string
      add :file_url, :string
      add :thumb_url, :string
      add :folder_id, :string, [references(:folders)]

      timestamps()
    end

  end
end
