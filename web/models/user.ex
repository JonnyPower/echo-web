defmodule Echo.User do
  use Echo.Web, :model

  schema "users" do
    field :name, :string
    field :password, :string

    has_many :devices, Echo.Device

    timestamps
  end

  @required_fields ~w(name password)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> update_change(:name, &String.downcase/1)
    |> validate_format(:name, ~r/[a-z0-9]/)
    |> validate_format(:password, ~r/^\$[0-9][a-z]\$.*$/)
    |> unique_constraint(:name, name: :user_unique_name)
  end
end
