import EctoEnum
defenum PlatformTypeEnum, :device_type, [:iOS, :android, :web]

defmodule Echo.Platform do
  use Echo.Web, :model

  schema "platforms" do
    field :version, :string
    field :type, PlatformTypeEnum

    has_many :devices, Echo.Device

    timestamps()
  end

  @required_fields ~w(version type)
  @optional_fields ~w()

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> validate_required([:version, :type])
    |> unique_constraint(:platform_unique, name: "platform_unique")
  end
end
