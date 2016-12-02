defmodule Echo.Repo.Migrations.RemoveTokenDistinct do
  use Ecto.Migration

  def change do
    drop unique_index(:devices, [:token], name: "device_unique_token")
    create unique_index(:devices, [:user_id, :name], name: "device_unique_user_name")

  end
end
