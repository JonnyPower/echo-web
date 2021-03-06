defmodule Echo.SessionTest do
  use Echo.ModelCase

  alias Comeonin.Bcrypt
  alias Echo.Session
  alias Echo.Repo
  alias Echo.User
  alias Echo.Client

  @valid_attrs %{token: "some content"}

  setup do
    user = Repo.insert!(User.changeset(%User{}, %{name: "test_user", password: Bcrypt.hashpwsalt("test_password")}))
    device = Repo.insert!(Ecto.build_assoc(user, :devices, %{token: "device token", name: "test device"}))
    client = Repo.insert!(Client.changeset(%Client{}, %{name: "EchoTest", version: "1.0", build: 1}))

    {:ok, device: device, client: client}
  end

  test "changeset with valid attributes and device", %{device: device, client: client} do
    changeset = Session.changeset(%Session{}, Map.put(@valid_attrs, :device_id, device.id))
    assert changeset.valid?
  end

  test "changeset with valid attributes but no device" do
    changeset = Session.changeset(%Session{}, @valid_attrs)
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset)
    end
  end

  test "changeset with device that doesn't exist", %{device: device, client: client} do
    changeset = Session.changeset(%Session{}, Map.put(@valid_attrs, :device_id, 100))
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset)
    end
  end

end
