defmodule Echo.Repo.Migrations.CreateSession do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :token, :string
      add :device_id, references(:devices, on_delete: :nothing)

      timestamps
    end
    create index(:sessions, [:device_id])
    create unique_index(:sessions, [:token], name: "session_unique_token")
    create unique_index(:sessions, [:device_id], name: "session_unique_device")

  end
end
