defmodule Echo.UserController do
  use Echo.Web, :controller
  alias Comeonin.Bcrypt
  alias Echo.User
  alias Echo.Device
  alias Echo.Session

  def register(conn, %{"name" => name, "password" => password, "confirm" => confirm_password}) do
    name = String.strip(name)
    cond do
      String.length(name) < 3 ->
        json conn, %{success: false, error: "NAME-LENGTH", message: "Name must be at least 3 characters"}
      String.length(password) < 6 ->
        json conn, %{success: false, error: "PASSWORD-LENGTH", message: "Password must be at least 6 characters"}
      password == confirm_password ->
        case Repo.get_by(User, name: name) do
          nil ->
            new_user = User.changeset(%User{}, %{name: name, password: Bcrypt.hashpwsalt(password)})
            case Repo.insert(new_user) do
              {:ok, _user} ->
                conn
                |> put_status(201)
                |> json(%{success: true})
              {:error, changeset} ->
                conn
                |> put_status(400)
                |> json(%{success: false, error: "INVALID", message: "Could not save user information"})
            end
          %User{} ->
            json conn, %{success: false, error: "EXISTS", message: "A user with that name has already been registered."}
        end
      true ->
        json conn, %{success: false, error: "PASSWORDS-DID-NOT-MATCH", message: "The passwords did not match."}
    end

  end

  def login(conn, %{
      "name" => name, 
      "password" => password, 
      "device" => %{
        "token" => device_token, 
        "name" => device_name, 
        "type" => device_type
      },
      "timezone" => timezone
    }) do

    case device_type do
      "iOS" ->
        name = name
        |> String.downcase

        user = Repo.get_by(User, name: name)

        if device_token == "" do
          device_token = nil
        end

        case user do
          nil ->
            conn
            |> put_status(404)
            |> json(%{success: false, error: "NOT-REGISTERED", message: "A user with that name is not registered."})
          user ->
            if Bcrypt.checkpw(password, user.password) do

              device = if device_token, do: Repo.get_by(Device, %{user_id: user.id, token: device_token}, else: nil)
              case device do
                nil ->
                  device = Ecto.build_assoc(user, :devices, %{token: device_token, name: device_name, type: device_type, token_status: :default})
                  case Repo.insert(device) do
                    {:ok, new_device} ->
                      device = new_device
                    {:error, changeset} ->
                      conn
                      |> put_status(400)
                      |> json(%{success: false, error: "INVALID", message: "Could not save device information"})
                  end
                %Device{} ->
                  changeset = Device.changeset(device, %{name: device_name, type: device_type})
                  case Repo.update(changeset) do
                    {:ok, new_device} ->
                      device = new_device
                    {:error, changeset} ->
                      conn
                      |> put_status(400)
                      |> json(%{success: false, error: "INVALID", message: "Could not update stored device information"})
                  end
              end

              session = Session
              |> Repo.get_by(device_id: device.id)

              if session != nil do
                end_session session
              end

              session_token = SecureRandom.base64(32)
              new_session = Ecto.build_assoc(device, :session, %{token: session_token, timezone: timezone})
              case Repo.insert(new_session) do
                {:ok, _session} ->
                  json conn, %{success: true, session_token: session_token}
                {:error, changeset} ->
                  conn
                  |> put_status(400)
                  |> json(%{success: false, error: "FAILED-TO-CREATE-SESSION", message: "Could not create a session with given parameters"})
              end

            else
              json conn, %{success: false, error: "INVALID-PASSWORD", message: "The password did not match our records"}
            end
        end
      _ ->
        json conn, %{success: false, error: "INVALID-DEVICE-TYPE", message: "The device type is not recognised"}
    end

  end

  def logout(conn, %{"session_token" => session_token}) do
    case Repo.get_by(Session, token: session_token) do
      session ->
        end_session session
    end
    json conn, %{success: true}
  end

  defp end_session(session) do
    session = Repo.preload session, :device
    Echo.Endpoint.broadcast("device_socket:#{session.device.id}", "disconnect", %{})
    Repo.delete(session)
  end

end
