defmodule Echo.Repo.Migrations.CreatePlatform do
  use Ecto.Migration

  def change do
    create table(:platforms) do
      add :type, :string
      add :version, :string

      timestamps()
    end
    create unique_index(:platforms, [:type, :version], name: "platform_unique")

    alter table(:devices) do
      add :platform_id, references(:platforms, on_delete: :nothing)
      remove :os_version
      remove :type
    end
    create index(:devices, [:platform_id])

  end
end
