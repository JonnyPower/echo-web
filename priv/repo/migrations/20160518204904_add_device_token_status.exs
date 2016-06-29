defmodule Echo.Repo.Migrations.AddDeviceTokenStatus do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :token_status, :string
    end
  end

end
