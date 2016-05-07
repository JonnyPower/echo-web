defmodule Echo.Device do
  use Echo.Web, :model

  schema "devices" do
    field :token, :string
    field :name, :string
    field :type, :string
    belongs_to :user, Echo.User, foreign_key: :user_id

    has_one :session, Echo.Session
    has_many :messages, Echo.Message

    timestamps
  end

  @required_fields ~w(name user_id type)
  @optional_fields ~w(token)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> assoc_constraint(:user)
    |> unique_constraint(:token, name: "device_unique_token")
  end
end
