defmodule Echo.NotificationTest do
  use Echo.ModelCase
  use Timex

  alias Echo.Notification

  alias Comeonin.Bcrypt
  alias Echo.Device
  alias Echo.User
  alias Echo.Message

  setup do
    user = Repo.insert!(User.changeset(%User{}, %{name: "test_user", password: Bcrypt.hashpwsalt("test_password")}))
    device = Repo.insert!(Ecto.build_assoc(user, :devices, %{name: "test device"}))
    message = Repo.insert!(Ecto.build_assoc(device, :messages, %{content: "some content", sent: DateTime.now}))

    {:ok, device: device, message: message}
  end

  test "changeset with valid attributes", %{device: device, message: message} do
    changeset = Notification.changeset(%Notification{}, %{message_id: message.id, device_id: device.id})
    assert changeset.valid?
    Repo.insert(changeset)
  end

  test "changeset with no device", %{device: device, message: message} do
    changeset = Notification.changeset(%Notification{}, %{message_id: message.id})
    refute changeset.valid?
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

  test "changeset with device that doesn't exist", %{device: device, message: message} do
    changeset = Notification.changeset(%Notification{}, %{message_id: message.id, device_id: 100})
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

  test "changeset with no message", %{device: device, message: message} do
    changeset = Notification.changeset(%Notification{}, %{device_id: device.id})
    refute changeset.valid?
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

  test "changeset with message that doesn't exist", %{device: device, message: message} do
    changeset = Notification.changeset(%Notification{}, %{message_id: 100, device_id: device.id})
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

end
