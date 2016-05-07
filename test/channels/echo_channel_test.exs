defmodule Echo.EchoChannelTest do
  use Echo.ChannelCase
  use Timex

  alias Comeonin.Bcrypt

  alias Echo.EchoChannel
  alias Echo.Repo
  alias Echo.User

  setup do
    {:ok, user} = Repo.insert(User.changeset(%User{}, %{name: "test_user", password: Bcrypt.hashpwsalt("test_password")}))
    {:ok, device} = Repo.insert(Ecto.build_assoc(user, :devices, %{name: "test_device", token: "test_device_token"}))
    {:ok, _} = Repo.insert(Ecto.build_assoc(device, :session, %{token: "test_session_token"}))

    {:ok, _, socket} =
      socket("device_id:" <> Integer.to_string(device.id), %{auth: %{user: %{id: user.id, name: user.name}, device: %{id: device.id, name: device.name}}})
      |> subscribe_and_join(EchoChannel, "echoes:" <> user.name)

    {:ok, socket: socket}
  end

  test "ping replies with status ok", %{socket: socket} do
    ref = push socket, "ping", %{"hello" => "there"}
    assert_reply ref, :ok, %{"hello" => "there"}
  end

  test "send message sent two days ago", %{socket: socket} do
    content = "test_content"
    
    sent_formatted = push_message(socket, content)

    assert_broadcast "message", %{id: _, content: content, sent: ^sent_formatted, from: %{name: "test_device", id: _}}
  end

  test "history for last day with sent two days ago", %{socket: socket} do
    content = "test_content"
    push_message(socket, content, 2)

    ref = push socket, "history", %{"days" => 1}
    assert_reply ref, :ok, %{messages: []}
  end

  test "history for last day with sent a day ago", %{socket: socket} do
    content = "test_content"
    sent_formatted = push_message(socket, content, 1)

    ref = push socket, "history", %{"days" => 1}
    assert_reply ref, :ok, %{messages: [%{id: _, content: content, sent: ^sent_formatted, from: %{name: "test_device", id: _}}]}
  end

  test "history for last two days with sent a day ago", %{socket: socket} do
    content = "test_content"
    sent_formatted = push_message(socket, content, 1)

    ref = push socket, "history", %{"days" => 2}
    assert_reply ref, :ok, %{messages: [%{id: _, content: content, sent: ^sent_formatted, from: %{name: "test_device", id: _}}]}
  end

  defp push_message(socket, content) do
    push_message(socket, content, 0)
  end

  defp push_message(socket, content, days) do
    sent_date = DateTime.now
    |> DateTime.shift(days: 0 - days)

    {:ok, sent_formatted} = sent_date
    |> Timex.format("{ISO:Extended}")

    push socket, "message", %{"content" => content, "sent" => sent_formatted}

    sent_formatted
  end

end
