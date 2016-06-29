defmodule Echo.UserSocket do
  use Phoenix.Socket
  alias Echo.Repo
  alias Echo.User
  alias Echo.Device
  alias Echo.Session
  import Ecto.Query, only: [from: 2]

  ## Channels
  channel "echoes:*", Echo.EchoChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  def connect(%{"token" => session_token}, socket) do
    query = from s in Session,
          join: d in Device, on: s.device_id == d.id,
          join: u in User, on: d.user_id == u.id,
          select: {u, d},
          where: s.token == ^session_token
    case Repo.one(query) do
      nil ->
        :error
      {user, device} ->
        {:ok, assign(socket, :auth, %{
          token: session_token,
          user: %{
            id: user.id,
            name: user.name
          },
          device: %{
            id: device.id,
            name: device.name
          }
        })}
    end
  end

  def id(socket), do: "device_socket:#{socket.assigns.auth.device.id}"

end
