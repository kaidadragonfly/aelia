defmodule Aelia.Repo.Migrations.ChangeProfileUrlToText do
  use Ecto.Migration

  def change do
    alter table("artists") do
      modify :profile_url, :text
    end
  end
end
