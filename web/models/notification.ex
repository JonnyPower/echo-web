defmodule Echo.Notification do
  use Echo.Web, :model

  schema "notifications" do
    belongs_to :message, Echo.Message
    belongs_to :device, Echo.Device

    timestamps
  end

  @required_fields ~w(message_id device_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> assoc_constraint(:message)
    |> assoc_constraint(:device)
  end
  
end
