defmodule Echo.EchoChannel do
  use Echo.Web, :channel
  use Timex
  alias Echo.User
  alias Echo.Device
  alias Echo.Message
  alias Echo.Repo
  alias Echo.Notify
  alias Echo.Session
  alias Echo.EchoPresence
  import Ecto.Query, only: [from: 2]

  def join("echoes:" <> name, _payload, socket) do
    send(self, :after_join)
    name = String.downcase(name)
    if socket.assigns.auth.user.name == name do
      session = Repo.get_by!(Session, token: socket.assigns.auth.token)
      {:ok, %{messages: history(0, socket.assigns.auth.user.id, session.timezone)}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info(:after_join, socket) do
    push socket, "presence_state", EchoPresence.list(socket)
    {:ok, _} = EchoPresence.track(socket, socket.assigns.auth.device.id, %{
      online_at: inspect(System.system_time(:seconds))
    })
    {:noreply, socket}
  end

  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("whoami", _payload, socket) do
    device = Repo.get!(Device, socket.assigns.auth.device.id)
    {:reply, {:ok, %{name: device.name, token: device.token, type: device.type}}, socket}
  end

  def handle_in("history", %{"days" => days}, socket) do
    session = Repo.get_by!(Session, token: socket.assigns.auth.token)
    {:reply, {:ok, %{messages: history(days, socket.assigns.auth.user.id, session.timezone)}}, socket}
  end

  def handle_in("message", %{"content" => content, "sent" => sent}, socket) do
    device = Repo.get!(Device, socket.assigns.auth.device.id)

    {:ok, date_sent} = sent
    |> Timex.parse("{ISO:Basic}")

    message = Message.changeset(%Message{}, %{content: content, sent: date_sent, device_id: device.id})

    #message = Ecto.build_assoc(device, :messages, %{content: content, sent: date_sent})
    case message.valid? do
      true ->
        case Repo.insert(message) do
          {:ok, message} ->
            broadcast_from! socket, "message", message_map(message)

            {:ok, pid} = Supervisor.start_child(Echo.Notify, [message, []])
            GenServer.cast(pid, :push)

            {:reply, {:ok, %{message_id: message.id}}, socket}
          {:error, error} ->
            {:reply, {:error, %{message: error}}, socket}
        end
      false ->
        IO.inspect(message)
        {:reply, {:error, %{errors: Enum.map(message.errors, & Echo.ErrorHelpers.translate_error(&1))}}, socket}
    end
  end

  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  defp history(days, user_id, timezone) do
    since = Timex.now(timezone)
    |> Timex.set([{:hour, 0}, {:minute, 0}, {:second, 0}])
    |> Timex.shift(days: 0 - days)

    query = from m in Message,
      join: d in Device, on: m.device_id == d.id,
      join: u in User, on: d.user_id == u.id,
      select: m,
      where: m.sent > ^since and u.id == ^user_id

    Repo.all(query)
    |> Enum.map(&message_map/1)
  end

  defp message_map(message) do
    message = message
    |> Repo.preload(:device)
    device = message.device
    |> Repo.preload(:platform)
    {:ok, sent_formattted} = Timex.format(message.sent, "{ISO:Basic:Z}")
    %{
      id: message.id,
      content: message.content,
      sent: sent_formattted,
      from: %{
        name: device.name,
        id: device.id,
        type: device.platform.type
      }
    }
  end

end
