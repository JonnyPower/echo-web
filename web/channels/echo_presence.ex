defmodule Echo.EchoPresence do
  use Phoenix.Presence, otp_app: :echo,
                        pubsub_server: Echo.PubSub
  import Ecto.Query
  alias Echo.Repo

  def fetch(_topic, entries) do

    query =
      from d in Echo.Device,
        preload: [:platform],
        where: d.id in ^Map.keys(entries),
        select: {d.id, d}

    devices = query |> Repo.all |> Enum.into(%{})

    IO.inspect(devices)

    for {key, %{metas: metas}} <- entries, into: %{} do
      keyInteger = String.to_integer(key)
      IO.inspect(keyInteger)
      IO.inspect(devices[keyInteger])
      {key, %{metas: metas, device: %{
        id: devices[keyInteger].id,
        name: devices[keyInteger].name,
        type: devices[keyInteger].platform.type
      }}}
    end
  end

end
