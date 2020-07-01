defmodule Aelia.Repo.Migrations.CascadeDeletes do
  use Ecto.Migration

  def change do
    alter table("folders") do
      modify :artist_id,
             references("artists", type: :string, on_delete: :delete_all),
             from: references("artists")
    end

    alter table("works") do
      modify :folder_id,
             references("folders", type: :string, on_delete: :delete_all),
             from: references("folders")
    end
  end
end
