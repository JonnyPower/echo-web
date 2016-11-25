defmodule Echo.Repo.Migrations.CreateClient do
  use Ecto.Migration

  def change do
    create table(:clients) do
      add :name, :string
      add :version, :string
      add :build, :integer

      timestamps()
    end
    create unique_index(:clients, [:name, :version, :build], name: "client_unique")

    alter table(:sessions) do
      add :client_id, references(:clients, on_delete: :nothing)
    end
    create index(:sessions, [:client_id])
  end
end
