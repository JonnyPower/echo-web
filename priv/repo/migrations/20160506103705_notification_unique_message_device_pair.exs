defmodule Echo.Repo.Migrations.NotificationUniqueMessageDevicePair do
  use Ecto.Migration

  def change do
    create unique_index(:notifications, [:message_id, :device_id])
  end
end
