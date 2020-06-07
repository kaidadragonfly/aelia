defmodule Aelia.Repo.Migrations.RequireArtistFields do
  use Ecto.Migration

  def change do
    alter table("artists") do
      modify :id, :string, null: false
      modify :profile_url, :string, null: false
    end
  end
end
