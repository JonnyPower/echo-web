defmodule Echo.Repo.Migrations.CreateNotification do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :message_id, references(:messages, on_delete: :nothing)
      add :device_id, references(:devices, on_delete: :nothing)

      timestamps
    end
    create index(:notifications, [:message_id])
    create index(:notifications, [:device_id])

  end
end
