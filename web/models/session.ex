defmodule Echo.Session do
  use Echo.Web, :model

  schema "sessions" do
    field :token, :string
    field :timezone, :string
    belongs_to :device, Echo.Device

    timestamps
  end

  @required_fields ~w(token device_id session)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:token, name: "session_unique_token")
    |> unique_constraint(:device_id, name: "session_unique_device")
    |> assoc_constraint(:device)
  end
end
