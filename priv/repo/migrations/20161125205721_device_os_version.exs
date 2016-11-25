defmodule Echo.Repo.Migrations.DeviceOsVersion do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :os_version, :string
    end
  end
end
