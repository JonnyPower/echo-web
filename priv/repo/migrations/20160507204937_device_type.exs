defmodule Echo.Repo.Migrations.DeviceType do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :type, :string
    end
  end
end
