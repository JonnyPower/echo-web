defmodule Echo.EchoChannel do
  use Echo.Web, :channel
  use Timex
  alias Echo.User
  alias Echo.Device
  alias Echo.Message
  alias Echo.Repo
  import Ecto.Query, only: [from: 2]

  def join("echoes:" <> name, _payload, socket) do
    if socket.assigns.auth.user.name == name do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("history", %{"days" => days}, socket) do
    since = DateTime.now
    |> DateTime.shift(days: 0 - days)

    query = from m in Message,
      join: d in Device, on: m.device_id == d.id,
      join: u in User, on: d.user_id == u.id,
      select: m,
      where: m.sent > ^since and u.id == ^socket.assigns.auth.user.id
    
    messages = Repo.all(query)
    |> Repo.preload(:device)
    |> Enum.map(
      fn(message) ->
        {:ok, sent_formattted} = Format.DateTime.Formatter.format(message.sent, "{ISO:Extended}")
        %{id: message.id, content: message.content, sent: sent_formattted, from: %{name: message.device.name, id: message.device.id}}
      end
    )

    {:reply, {:ok, %{messages: messages}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (echoes:lobby).
  def handle_in("message", %{"content" => content, "sent" => sent}, socket) do
    device = Repo.get!(Device, socket.assigns.auth.device.id)
    
    {:ok, date_sent} = sent
    |> Parse.DateTime.Parser.parse("{ISO:Extended}")

    message = Ecto.build_assoc(device, :messages, %{content: content, sent: date_sent})
    case Repo.insert(message) do
      {:ok, message} ->
        broadcast socket, "message", %{id: message.id, content: content, sent: sent, from: %{name: socket.assigns.auth.device.name, id: socket.assigns.auth.device.id}}
        {:noreply, socket}
      {:error, error} ->
        {:reply, {:error, %{message: error}}, socket}
    end
  end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

end
