defmodule Echo.MessageTest do
  use Echo.ModelCase

  alias Comeonin.Bcrypt
  alias Echo.Message
  alias Echo.Repo
  alias Echo.User

  @valid_attrs %{content: "some content", sent: "2016-05-05T13:00:00Z"}

  setup do
    {:ok, user} = Repo.insert(User.changeset(%User{}, %{name: "test_user", password: Bcrypt.hashpwsalt("test_password")}))
    {:ok, device} = Repo.insert(Ecto.build_assoc(user, :devices, %{token: "device token", name: "test device"}))

    {:ok, device: device}
  end

  test "changeset with valid attributes with device", %{device: device} do
    changeset = Message.changeset(%Message{}, Map.put(@valid_attrs, :device_id, device.id))
    assert changeset.valid?
    Repo.insert!(changeset)
  end

  test "changeset with valid attributes but no device" do
    changeset = Message.changeset(%Message{}, @valid_attrs)
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

  test "changeset with device that doesn't exist", %{device: device} do
    changeset = Message.changeset(%Message{}, Map.put(@valid_attrs, :device_id, 100))
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

  test "changeset with invalid sent date", %{device: device} do
    changeset = Message.changeset(%Message{}, %{Map.put(@valid_attrs, :device_id, device.id) | sent: "qwerty"})
    refute changeset.valid?
  end

  test "changeset with invalid invalid content", %{device: device} do
    changeset = Message.changeset(%Message{}, %{Map.put(@valid_attrs, :device_id, device.id) | content: ""})
    refute changeset.valid?
  end

end
