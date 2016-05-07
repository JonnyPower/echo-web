defmodule Echo.UserTest do
  use Echo.ModelCase

  alias Comeonin.Bcrypt
  alias Echo.User
  alias Echo.Repo

  @valid_attrs %{name: "testusername", password: Bcrypt.hashpwsalt("some password")}
  @invalid_attrs %{name: "test username", password: "blah"}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "username lowercase" do
    changeset = User.changeset(%User{}, %{name: "TESTUSERNAME", password: Bcrypt.hashpwsalt("some password")})
    user = Repo.insert!(changeset)
    assert user.name == "testusername"
  end

  test "changeset with same name as inserted" do
    changeset = User.changeset(%User{}, @valid_attrs)
    Repo.insert!(changeset)

    changeset = User.changeset(%User{}, @valid_attrs)
    assert_raise MatchError, fn ->
      {:ok, _} = Repo.insert(changeset) 
    end
  end

end
