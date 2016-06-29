defmodule Echo.Repo.Migrations.CreateDevice do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :token, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:devices, [:user_id])
    create unique_index(:devices, [:token], name: "device_unique_token")

  end
end
