defmodule Echo.Repo.Migrations.DeviceName do
  use Ecto.Migration

  def change do
    alter table(:devices) do
      add :name, :string # Database type
    end
  end

end
