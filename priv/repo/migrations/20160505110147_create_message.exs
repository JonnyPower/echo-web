defmodule Echo.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text
      add :sent, :datetime
      add :device_id, references(:devices, on_delete: :nothing)

      timestamps
    end
    create index(:messages, [:device_id])

  end
end
