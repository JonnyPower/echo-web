defmodule Echo.EchoChannelTest do
  use Echo.ChannelCase
  use Timex

  alias Comeonin.Bcrypt

  alias Echo.EchoChannel
  alias Echo.Repo
  alias Echo.User
  alias Echo.Message

  setup do
    {:ok, user} = Repo.insert(User.changeset(%User{}, %{name: "test_user", password: Bcrypt.hashpwsalt("test_password")}))
    {:ok, device} = Repo.insert(Ecto.build_assoc(user, :devices, %{name: "test_device", token: "test_device_token"}))
    {:ok, session} = Repo.insert(Ecto.build_assoc(device, :session, %{token: "test_session_token"}))

    {:ok, _, socket} =
      socket("device_id:" <> Integer.to_string(device.id), %{auth: %{user: %{id: user.id, name: user.name}, device: %{id: device.id, name: device.name}}})
      |> subscribe_and_join(EchoChannel, "echoes:" <> user.name)

    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "send message", %{socket: socket} do
    content = "test_content"

    {:ok, sent_date} = "2016-05-05T13:00:00Z"
    |> Parse.DateTime.Parser.parse("{ISO:Extended}")
    {:ok, sent_formatted} = sent_date
    |> Format.DateTime.Formatter.format("{ISO:Extended}")

    ref = push socket, "message", %{"content" => content, "sent" => sent_formatted}
    assert_broadcast "message", %{id: _, content: content, sent: sent_formatted, from: %{name: "test_device", id: _}}
  end

  test "history", %{socket: socket} do
    
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
