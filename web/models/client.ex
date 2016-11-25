defmodule Echo.Client do
  use Echo.Web, :model

  schema "clients" do
    field :name, :string
    field :version, :string
    field :build, :integer

    has_many :sessions, Echo.Session

    timestamps()
  end

  @required_fields ~w(name version build)
  @optional_fields ~w()

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields, @optional_fields)
    |> update_change(:name, &String.downcase/1)
    |> cast(params, [:name, :version, :build])
    |> validate_required([:name, :version, :build])
    |> unique_constraint(:client_unique, name: "client_unique")
  end
end
