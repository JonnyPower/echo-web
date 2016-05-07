defmodule Echo.UserSocket do
  use Phoenix.Socket
  alias Echo.Repo
  alias Echo.User
  alias Echo.Device
  alias Echo.Session
  import Ecto.Query, only: [from: 2]

  ## Channels
  # channel "rooms:*", Echo.RoomChannel
  channel "echoes:*", Echo.EchoChannel

  ## Transports
  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
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
        {:ok, assign(socket, :auth, %{token: session_token, user: %{id: user.id, name: user.name}, device: %{id: device.id, name: device.name}})}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "users_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     Echo.Endpoint.broadcast("users_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(socket), do: "device_socket:#{socket.assigns.auth.device.id}"

end
