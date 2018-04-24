defmodule Margaret.UserTest do
  use Margaret.DataCase

  @valid_attrs %{
    username: ExMachina.sequence(:username, &"username-#{&1}"),
    email: ExMachina.sequence(:email, &"email#{&1}@example.com"),
    settings: Factory.params_for(:user_settings)
  }

  describe "changeset/1" do
    test "is valid when the attributes are valid" do
      %Changeset{valid?: valid_changeset?} = User.changeset(@valid_attrs)

      assert valid_changeset?
    end

    test "is invalid when the username is invalid" do
      attrs = %{@valid_attrs | username: "bad_#@%!_*username&&+"}

      %Changeset{valid?: valid_changeset?} = User.changeset(attrs)

      refute valid_changeset?
    end

    test "is invalid when the email is invalid" do
      attrs = %{@valid_attrs | email: "bad_email"}

      %Changeset{valid?: valid_changeset?} = User.changeset(attrs)

      refute valid_changeset?
    end
  end

  describe "update_changeset/2" do
    test "is valid when the attributes are valid" do
      user = Factory.insert(:user)

      %Changeset{valid?: valid_changeset?} = User.update_changeset(user, @valid_attrs)

      assert valid_changeset?
    end

    test "is invalid when the username is invalid" do
      user = Factory.insert(:user)
      invalid_attrs = %{@valid_attrs | username: "bad_#@%!_*username&&+"}

      %Changeset{valid?: valid_changeset?} = User.update_changeset(user, invalid_attrs)

      refute valid_changeset?
    end

    test "is invalid when the email is invalid" do
      user = Factory.insert(:user)
      attrs = %{@valid_attrs | email: "bad_email"}

      %Changeset{valid?: valid_changeset?} = User.update_changeset(user, attrs)

      refute valid_changeset?
    end
  end

  describe "valid_username?/1" do
    test "returns true when the username is valid" do
      username = "username"

      assert User.valid_username?(username)
    end

    test "returns false when the username is invalid" do
      username = "__bad_username__"

      refute User.valid_username?(username)
    end
  end

  describe "active/1" do
    test "doesn't match deactivated users" do
      Factory.insert_list(3, :user, deactivated_at: NaiveDateTime.utc_now())

      query = User.active()

      active_user_count = Repo.count(query)

      assert active_user_count === 0
    end

    test "matches active users" do
      active_user_count = 5
      Factory.insert_list(active_user_count, :user)

      query = User.active()

      actual_count = Repo.count(query)

      assert actual_count === active_user_count
    end

    test "matches only active users" do
      active_user_count = 5
      Factory.insert_list(active_user_count, :user)

      Factory.insert_list(2, :user, deactivated_at: NaiveDateTime.utc_now())

      query = User.active()

      actual_count = Repo.count(query)

      assert actual_count === active_user_count
    end
  end
end
