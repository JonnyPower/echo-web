defmodule Echo.SessionTest do
  use Echo.ModelCase

  alias Comeonin.Bcrypt
  alias Echo.Session
  alias Echo.Repo
  alias Echo.User

  @valid_attrs %{token: "some content"}

  setup do
    user = Repo.insert!(User.changeset(%User{}, %{name: "test_user", password: Bcrypt.hashpwsalt("test_password")}))
    device = Repo.insert!(Ecto.build_assoc(user, :devices, %{token: "device token", name: "test device"}))

    {:ok, device: device}
  end

  test "changeset with valid attributes and device", %{device: device} do
    changeset = Session.changeset(%Session{}, Map.put(@valid_attrs, :device_id, device.id))
    assert changeset.valid?
  end

  test "changeset with valid attributes but no device" do
    changeset = Session.changeset(%Session{}, @valid_attrs)
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

  test "changeset with device that doesn't exist", %{device: device} do
    changeset = Session.changeset(%Session{}, Map.put(@valid_attrs, :device_id, 100))
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

end
