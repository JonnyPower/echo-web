defmodule Echo.UserControllerTest do
  use Echo.ConnCase

  alias Comeonin.Bcrypt
  alias Echo.User
  alias Echo.Repo

  test "register valid", %{conn: conn} do
    conn = post conn, "/api/register", %{"name" => "testusername", "password" => "password"}
    json_response(conn, 200) == %{"success" => true}
  end

  test "register invalid username", %{conn: conn} do

  end

  test "register invalid password", %{conn: conn} do

  end

  test "register same username", %{conn: conn} do

  end

  test "login with correct details", %{conn: conn} do
    user = insert_user("testusername", "password")

    conn = post conn, "/api/login", %{name: user.name, password: "password", deivce: %{token: "device_token", name: "EchoTestDevice", type: "iOS"}, client: %{name: "EchoTestClient", version: "1.0", build: 1}}
    json_response(conn, 200) == %{"success" => true}
  end

  test "login with incorrect details", %{conn: conn} do

  end

  test "login with same device twice", %{conn: conn} do

  end

  test "login with same device twice with new device name", %{conn: conn} do

  end

  test "login with second device valid", %{conn: conn} do

  end

  test "login with second device same token as first", %{conn: conn} do

  end

  test "logout with matching tokens", %{conn: conn} do
    user = insert_user("testusername", "password")

    conn = post conn, "/api/login", %{name: user.name, password: "password", device_token: "device_token", device_name: "test_device"}

  end

  test "logout without matching tokens", %{conn: conn} do

  end

  defp insert_user(name, password) do
    Repo.insert!(User.changeset(%User{}, %{name: name, password: Bcrypt.hashpwsalt(password)}))
  end

end
