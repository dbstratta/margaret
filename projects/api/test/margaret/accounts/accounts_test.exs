defmodule Margaret.AccountsTest do
  use Margaret.DataCase

  @valid_attrs %{
    username: ExMachina.sequence(:username, &"username-#{&1}"),
    email: ExMachina.sequence(:email, &"email#{&1}@example.com"),
    settings: Factory.params_for(:user_settings)
  }

  @invalid_attrs %{
    username: "__bad_username__",
    email: "__bad_email__"
  }

  describe "insert_user/1" do
    test "inserts a user when the attributes are valid" do
      assert {:ok, %User{} = user} = Accounts.insert_user(@valid_attrs)
      assert user.username === @valid_attrs.username
      assert user.email === @valid_attrs.email
    end

    test "doesn't insert a user when the email is invalid" do
      invalid_attrs = %{@valid_attrs | email: @invalid_attrs.email}

      assert {:error, _} = Accounts.insert_user(invalid_attrs)
    end

    test "doesn't insert a user when the username has been already used" do
      username = "test"

      Factory.insert(:user, username: username)

      invalid_attrs = %{@valid_attrs | username: username}
      assert {:error, _} = Accounts.insert_user(invalid_attrs)
    end

    test "doesn't insert a user when the email has been already used" do
      email = "user@example.com"

      Factory.insert(:user, email: email)

      invalid_attrs = %{@valid_attrs | email: email}
      assert {:error, _} = Accounts.insert_user(invalid_attrs)
    end
  end

  describe "update_user/2" do
    test "updates a user when the attributes are valid" do
      user = Factory.insert(:user)

      new_email = ExMachina.sequence(:email, &"email#{&1}@example.com")
      new_username = ExMachina.sequence(:username, &"user#{&1}")

      assert user.email != new_email
      assert user.username != new_username

      attrs = %{@valid_attrs | email: new_email, username: new_username}

      assert {:ok, %User{} = updated_user} = Accounts.update_user(user, attrs)

      assert updated_user.email === new_email
      assert updated_user.username === new_username
    end

    test "doesn't update a user when the attributes are invalid" do
      user = Factory.insert(:user)

      attrs = %{@valid_attrs | email: @invalid_attrs.email, username: @invalid_attrs.username}

      assert {:error, _} = Accounts.update_user(user, attrs)
    end
  end

  describe "get_user/2" do
    test "returns the user when there is a user with that id" do
      %User{id: user_id} = Factory.insert(:user)

      assert %User{id: ^user_id} = Accounts.get_user(user_id)
    end

    test "returns nil when there isn't a user with that id" do
      user_id = 1

      assert is_nil(Accounts.get_user(user_id))
    end

    test "doesn't return deactivated users by default" do
      %User{id: user_id} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert is_nil(Accounts.get_user(user_id))
    end

    test "returns deactivated users when include_deactivated is true" do
      %User{id: user_id} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert %User{id: ^user_id} = Accounts.get_user(user_id, include_deactivated: true)
    end
  end

  describe "get_user!/2" do
    test "returns the user when there is a user with that id" do
      %User{id: user_id} = Factory.insert(:user)

      assert %User{id: ^user_id} = Accounts.get_user!(user_id)
    end

    test "raises when there isn't a user with that id" do
      user_id = System.unique_integer([:positive])

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(user_id)
      end
    end

    test "doesn't return deactivated users by default" do
      %User{id: user_id} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(user_id)
      end
    end

    test "returns deactivated users when include_deactivated is true" do
      %User{id: user_id} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert %User{id: ^user_id} = Accounts.get_user!(user_id, include_deactivated: true)
    end
  end

  describe "get_user_by_username/2" do
    test "returns the user when there is a user with that username" do
      %User{username: username} = Factory.insert(:user)

      assert %User{username: ^username} = Accounts.get_user_by_username(username)
    end

    test "returns nil when there isn't a user with that username" do
      username = ExMachina.sequence(:username, &"user#{&1}")

      assert is_nil(Accounts.get_user_by_username(username))
    end

    test "doesn't return deactivated users by default" do
      %User{username: username} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert is_nil(Accounts.get_user_by_username(username))
    end

    test "returns deactivated users when include_deactivated is true" do
      %User{username: username} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert %User{username: ^username} =
               Accounts.get_user_by_username(username, include_deactivated: true)
    end
  end

  describe "get_user_by_username!/2" do
    test "returns the user when there is a user with that username" do
      %User{username: username} = Factory.insert(:user)

      assert %User{username: ^username} = Accounts.get_user_by_username!(username)
    end

    test "raises when there isn't a user with that username" do
      username = ExMachina.sequence(:username, &"user#{&1}")

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_username!(username)
      end
    end

    test "doesn't return deactivated users by default" do
      %User{username: username} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_username!(username)
      end
    end

    test "returns deactivated users when include_deactivated is true" do
      %User{username: username} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert %User{username: ^username} =
               Accounts.get_user_by_username!(username, include_deactivated: true)
    end
  end

  describe "get_user_by_email/2" do
    test "returns the user when there is a user with that email" do
      %User{email: email} = Factory.insert(:user)

      assert %User{email: ^email} = Accounts.get_user_by_email(email)
    end

    test "returns nil when there isn't a user with that username" do
      email = ExMachina.sequence(:email, &"email#{&1}@example.com")

      assert is_nil(Accounts.get_user_by_email(email))
    end

    test "doesn't return deactivated users by default" do
      %User{email: email} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert is_nil(Accounts.get_user_by_email(email))
    end

    test "returns deactivated users when include_deactivated is true" do
      %User{email: email} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert %User{email: ^email} = Accounts.get_user_by_email(email, include_deactivated: true)
    end
  end

  describe "get_user_by_email!/2" do
    test "returns the user when there is a user with that email" do
      %User{email: email} = Factory.insert(:user)

      assert %User{email: ^email} = Accounts.get_user_by_email!(email)
    end

    test "raises when there isn't a user with that email" do
      email = ExMachina.sequence(:email, &"user#{&1}@example.com")

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_email!(email)
      end
    end

    test "doesn't return deactivated users by default" do
      %User{email: email} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_email!(email)
      end
    end

    test "returns deactivated users when include_deactivated is true" do
      %User{email: email} = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())

      assert %User{email: ^email} = Accounts.get_user_by_email!(email, include_deactivated: true)
    end
  end

  describe "get_user_by_social_login!/2" do
    test "returns the user when there is a user linked to that social login" do
      %User{id: user_id} = user = Factory.insert(:user)
      %SocialLogin{provider: provider, uid: uid} = Factory.insert(:social_login, user: user)

      assert %User{id: ^user_id} = Accounts.get_user_by_social_login!({provider, uid})
    end

    test "raises when there isn't a user linked to that social login" do
      provider = "facebook"
      uid = ExMachina.sequence(:uid, &"uid#{&1}")

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_social_login!({provider, uid})
      end
    end

    test "" do
      %User{} = user = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())
      %SocialLogin{provider: provider, uid: uid} = Factory.insert(:social_login, user: user)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_social_login!({provider, uid})
      end
    end

    test "returns deactivated users when include_deactivated is true" do
      %User{id: user_id} = user = Factory.insert(:user, deactivated_at: NaiveDateTime.utc_now())
      %SocialLogin{provider: provider, uid: uid} = Factory.insert(:social_login, user: user)

      assert %User{id: ^user_id} =
               Accounts.get_user_by_social_login!({provider, uid}, include_deactivated: true)
    end
  end

  describe "user_count/1" do
    test "returns the user count" do
      active_user_count = 3
      deactivated_user_count = 2
      total_user_count = active_user_count + deactivated_user_count

      Factory.insert_list(active_user_count, :user)
      Factory.insert_list(deactivated_user_count, :user, deactivated_at: NaiveDateTime.utc_now())

      assert Accounts.user_count() === active_user_count
      assert Accounts.user_count(include_deactivated: true) === total_user_count
    end
  end

  describe "delete_user/1" do
    test "deletes the user when the user exists" do
      %User{id: user_id} = user = Factory.insert(:user)

      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert is_nil(Accounts.get_user(user_id))
    end
  end
end
