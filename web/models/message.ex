defmodule Echo.Message do
  use Echo.Web, :model

  schema "messages" do
    field :content, :string
    field :sent, Timex.Ecto.DateTime
    belongs_to :device, Echo.Device

    timestamps
  end

  @required_fields ~w(content sent device_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:content, min: 1, max: 4096)
    |> assoc_constraint(:device)
  end

end
