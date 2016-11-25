defmodule Echo.PlatformTest do
  use Echo.ModelCase

  alias Echo.Platform

  @valid_attrs %{version: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Platform.changeset(%Platform{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Platform.changeset(%Platform{}, @invalid_attrs)
    refute changeset.valid?
  end
end
