defmodule Echo.GCMWorker do
  use GenServer
  alias Echo.Repo
  alias Echo.User
  alias Echo.Device

  import Ecto.Query, only: [from: 2]

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(message) do
    {:ok, message}
  end

  def handle_cast(:push, message) do
    message = message
    |> Repo.preload(:device)

    device = message.device
    |> Repo.preload(:user)

    tokens = from(d in Device,
      join: u in User, on: d.user_id == u.id,
      select: d.token,
      where: u.id == ^device.user.id
        and d.id != ^device.id
        and not is_nil(d.token)
        and d.token != ""
        and d.token_status != "invalid"
        and d.token_status != "not_registered")
    |> Repo.all
    |> MapSet.new

    push(tokens, message.content)

    {:stop, :normal, message}
  end

  defp push([], _) do
  end

  defp push(tokens, message_content) do
    api_key = Application.get_env(:echo, Echo.GCMWorker)[:api_key]
    gcm_response = GCM.push(api_key, MapSet.to_list(tokens), %{
      notification: %{
        sound: "default",
        alert: "default",
        body: message_content,
        badge: "1"
      },
      content_available: true,
      priority: "high"
    })
    IO.inspect(gcm_response)
    handle_response(gcm_response, message_content, tokens)
  end

  defp handle_response({:error, :unauthorized}, _, _) do
    # Configuration error
  end

  defp handle_response({:ok, response}, message_content, tokens) do
    response
    |> handle_not_registered_ids
    |> handle_invalid_registration_ids
    |> handle_canonical_ids
    |> handle_successful_ids(tokens)
    |> handle_to_be_retried_ids(message_content)
  end

  defp handle_not_registered_ids(%{
    not_registered_ids: not_registered_ids
  } = response) do
    update_token_status(not_registered_ids, :not_registered)

    response
  end

  defp handle_invalid_registration_ids(%{
    invalid_registration_ids: invalid_registration_ids
  } = response) do
    update_token_status(invalid_registration_ids, :invalid)

    response
  end

  defp handle_canonical_ids(%{
    canonical_ids: canonical_ids
  } = response) do
    canonical_ids
    |> Enum.map(fn %{old: old, new: new} ->
      device = Repo.get_by(Device, token: old)
      changeset = Device.changeset(device, %{token: new})
      Repo.update(changeset)
    end)

    response
  end

  defp handle_to_be_retried_ids(%{
    to_be_retried_ids: to_be_retried_ids
  }, message_content) do
    push(to_be_retried_ids, message_content)
  end

  defp handle_successful_ids(%{
    to_be_retried_ids: to_be_retried_ids,
    invalid_registration_ids: invalid_registration_ids,
    not_registered_ids: not_registered_ids
  } = response, tokens) do
    not_successul_tokens = MapSet.new(to_be_retried_ids ++ invalid_registration_ids ++ not_registered_ids)

    successful_tokens = tokens
    |> MapSet.difference(not_successul_tokens)
    update_token_status(successful_tokens, :registered)

    response
  end

  defp update_token_status(tokens, new_token_status) do
    tokens
    |> Enum.map(fn token ->
      device = Repo.get_by(Device, token: token)
      changeset = Device.changeset(device, %{token_status: new_token_status})
      Repo.update(changeset)
    end)
  end

end
