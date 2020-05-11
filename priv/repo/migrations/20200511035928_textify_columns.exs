defmodule Aelia.Repo.Migrations.TextifyColumns do
  use Ecto.Migration

  def change do
    alter table("artists") do
      modify :name, :text
      modify :username, :text
      modify :profile_url, :text
      modify :icon_url, :text
    end

    alter table("folders") do
      modify :name, :text
    end

    alter table("works") do
      modify :file_url, :text
      modify :page_url, :text
      modify :thumb_url, :text
      modify :title, :text
    end
  end
end
