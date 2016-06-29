defmodule Echo.Repo.Migrations.SessionTimezone do
  use Ecto.Migration

  def change do
    alter table(:sessions) do
      add :timezone, :string # Database type
    end
  end
end
