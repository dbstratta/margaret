defmodule Margaret.AccountsTest do
  use Margaret.DataCase

  test "changeset/1 with valid attributes" do
    attrs = %{
      username: "user#{System.unique_integer()}",
      email: "user#{System.unique_integer()}@example.com"
    }

    %Changeset{valid?: valid?} = User.changeset(attrs)

    assert valid?
  end

  test "changeset/1 with invalid attributes" do
    attrs = %{
      username: "bad#@%!_username+",
      email: "user#{System.unique_integer()}@example.com"
    }

    %Changeset{valid?: valid?} = User.changeset(attrs)

    refute valid?
  end
end
