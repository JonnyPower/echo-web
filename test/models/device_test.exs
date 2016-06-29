defmodule Echo.DeviceTest do
  use Echo.ModelCase

  alias Comeonin.Bcrypt
  alias Echo.Device
  alias Echo.User

  @valid_attrs %{token: "device token", name: "test device", type: :iOS, token_status: :default}

  setup do
    {:ok, user} = Repo.insert(User.changeset(%User{}, %{name: "test_user", password: Bcrypt.hashpwsalt("test_password")}))

    {:ok, user: user}
  end

  test "changeset with valid attributes and user", %{user: user} do
    changeset = Device.changeset(%Device{}, Map.put(@valid_attrs, :user_id, user.id))
    assert changeset.valid?
  end

  test "changeset with valid attributes but no user" do
    changeset = Device.changeset(%Device{}, @valid_attrs)
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

  test "changeset with user that doesn't exist", %{user: user} do
    changeset = Device.changeset(%Device{}, Map.put(@valid_attrs, :user_id, 100))
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

  test "changeset with no token", %{user: user} do
    changeset = Device.changeset(%Device{}, Map.drop(Map.put(@valid_attrs, :user_id, user.id), [:token]))
    assert changeset.valid?
  end

  test "changeset with no name", %{user: user} do
    changeset = Device.changeset(%Device{}, Map.drop(Map.put(@valid_attrs, :user_id, user.id), [:name]))
    refute changeset.valid?
  end

end
