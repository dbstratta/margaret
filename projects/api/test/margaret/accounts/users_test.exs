defmodule Margaret.UsersTest do
  use Margaret.DataCase

  @valid_attrs %{
    username: "user#{System.unique_integer()}",
    email: "user#{System.unique_integer()}@example.com"
  }

  @invalid_attrs %{
    username: "invalid_username!!@#$%%^&**",
    email: "invalid_email"
  }

  describe "changeset/1" do
    test "with valid attributes" do
      %Changeset{valid?: changeset_valid?} = User.changeset(@valid_attrs)

      assert changeset_valid?
    end

    test "with invalid username" do
      attrs = %{@valid_attrs | username: "bad_#@%!_*username&&+"}

      %Changeset{valid?: changeset_valid?} = User.changeset(attrs)

      refute changeset_valid?
    end

    test "with invalid email" do
      attrs = %{@valid_attrs | email: "bad_email"}

      %Changeset{valid?: changeset_valid?} = User.changeset(attrs)

      refute changeset_valid?
    end
  end

  describe "update_changeset/2" do
    test "with valid attributes" do
      user = Factory.build_user()

      %Changeset{valid?: changeset_valid?} = User.update_changeset(user, @valid_attrs)

      assert changeset_valid?
    end

    test "with invalid username" do
      user = Factory.build_user()
      invalid_attrs = %{@valid_attrs | username: "bad_#@%!_*username&&+"}

      %Changeset{valid?: changeset_valid?} = User.update_changeset(user, invalid_attrs)

      refute changeset_valid?
    end

    test "with invalid email" do
      user = Factory.build_user()
      attrs = %{@valid_attrs | email: "bad_email"}

      %Changeset{valid?: changeset_valid?} = User.update_changeset(user, attrs)

      refute changeset_valid?
    end
  end

  describe "insert_user/1" do
    test "with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.insert_user(@valid_attrs)
      assert user.username == @valid_attrs.username
      assert user.email == @valid_attrs.email
    end

    test "with invalid data doesn't create a user" do
      invalid_attrs = %{@valid_attrs | email: "bad_email"}

      assert {:error, _} = Accounts.insert_user(invalid_attrs)
    end

    test "with duplicated username doesn't create a user" do
      username = "pepe"

      Factory.insert_user!(username: username)

      invalid_attrs = %{@valid_attrs | username: username}
      assert {:error, _} = Accounts.insert_user(invalid_attrs)
    end

    test "with duplicated email doesn't create a user" do
      email = "user@example.com"

      Factory.insert_user!(email: email)

      invalid_attrs = %{@valid_attrs | email: email}
      assert {:error, _} = Accounts.insert_user(invalid_attrs)
    end
  end

  describe "update_user/2" do
    test "with valid data updates the user" do
      user =
        Factory.insert_user!(
          username: "user#{System.unique_integer()}",
          email: "user#{System.unique_integer()}@example.com"
        )

      new_email = "user#{System.unique_integer()}@example.com"
      new_username = "user#{System.unique_integer()}"

      assert user.email != new_email
      assert user.username != new_username

      attrs = %{@valid_attrs | email: new_email, username: new_username}

      assert {:ok, %User{} = updated_user} = Accounts.update_user(user, attrs)

      assert updated_user.email == new_email
      assert updated_user.username == new_username
    end

    test "with invalid data doesn't update the user" do
      user = Factory.insert_user!()

      attrs = %{@valid_attrs | email: @invalid_attrs.email, username: @invalid_attrs.username}

      assert {:error, _} = Accounts.update_user(user, attrs)
    end
  end

  describe "get_user/2" do
    test "with valid id gets the user" do
      %User{id: user_id} = Factory.insert_user!()

      assert %User{id: ^user_id} = Accounts.get_user(user_id)
    end

    test "with invalid id returns nil" do
      user_id = System.unique_integer([:positive])

      assert is_nil(Accounts.get_user(user_id))
    end

    test "including deactivated users" do
      %User{id: user_id} = Factory.insert_user!(deactivated_at: NaiveDateTime.utc_now())

      assert is_nil(Accounts.get_user(user_id))
      assert %User{id: ^user_id} = Accounts.get_user(user_id, include_deactivated: true)
    end
  end

  describe "get_user!/2" do
    test "with valid id gets the user" do
      %User{id: user_id} = Factory.insert_user!()

      assert %User{id: ^user_id} = Accounts.get_user!(user_id)
    end

    test "with invalid id raises Ecto.NoResultsError" do
      user_id = System.unique_integer([:positive])

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(user_id)
      end
    end

    test "including deactivated users" do
      %User{id: user_id} = Factory.insert_user!(deactivated_at: NaiveDateTime.utc_now())

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(user_id)
      end

      assert %User{id: ^user_id} = Accounts.get_user!(user_id, include_deactivated: true)
    end
  end

  describe "get_user_by_username/2" do
    test "with valid username gets the user" do
      %User{username: username} = Factory.insert_user!()

      assert %User{username: ^username} = Accounts.get_user_by_username(username)
    end

    test "with invalid username returns nil" do
      username = "user#{System.unique_integer()}"

      assert is_nil(Accounts.get_user_by_username(username))
    end

    test "including deactivated users" do
      %User{username: username} = Factory.insert_user!(deactivated_at: NaiveDateTime.utc_now())

      assert is_nil(Accounts.get_user_by_username(username))

      assert %User{username: ^username} =
               Accounts.get_user_by_username(username, include_deactivated: true)
    end
  end

  describe "get_user_by_username!/2" do
    test "with valid username gets the user" do
      %User{username: username} = Factory.insert_user!()

      assert %User{username: ^username} = Accounts.get_user_by_username!(username)
    end

    test "with invalid username raises Ecto.NoResultsError" do
      username = "user#{System.unique_integer()}"

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_username!(username)
      end
    end

    test "including deactivated users" do
      %User{username: username} = Factory.insert_user!(deactivated_at: NaiveDateTime.utc_now())

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_username!(username)
      end

      assert %User{username: ^username} =
               Accounts.get_user_by_username!(username, include_deactivated: true)
    end
  end

  describe "get_user_by_email/2" do
    test "with valid email gets the user" do
      %User{email: email} = Factory.insert_user!()

      assert %User{email: ^email} = Accounts.get_user_by_email(email)
    end

    test "with invalid email returns nil" do
      email = "user#{System.unique_integer()}@example.com"

      assert is_nil(Accounts.get_user_by_email(email))
    end

    test "including deactivated users" do
      %User{email: email} = Factory.insert_user!(deactivated_at: NaiveDateTime.utc_now())

      assert is_nil(Accounts.get_user_by_email(email))

      assert %User{email: ^email} = Accounts.get_user_by_email(email, include_deactivated: true)
    end
  end

  describe "get_user_by_email!/2" do
    test "with valid email gets the user" do
      %User{email: email} = Factory.insert_user!()

      assert %User{email: ^email} = Accounts.get_user_by_email!(email)
    end

    test "with invalid email raises Ecto.NoResultsError" do
      email = "user#{System.unique_integer()}@example.com"

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_email!(email)
      end
    end

    test "including deactivated users" do
      %User{email: email} = Factory.insert_user!(deactivated_at: NaiveDateTime.utc_now())

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_email!(email)
      end

      assert %User{email: ^email} = Accounts.get_user_by_email!(email, include_deactivated: true)
    end
  end

  describe "get_user_by_social_login!/2" do
    test "with valid data gets the user" do
      %User{id: user_id} = Factory.insert_user!()
      %SocialLogin{provider: provider, uid: uid} = Factory.insert_social_login!(user_id: user_id)

      assert %User{id: ^user_id} = Accounts.get_user_by_social_login!({provider, uid})
    end

    test "with invalid data raises Ecto.NoResultsError" do
      provider = "facebook"
      uid = "#{System.unique_integer([:positive])}"

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_social_login!({provider, uid})
      end
    end

    test "including deactivated users" do
      %User{id: user_id} = Factory.insert_user!(deactivated_at: NaiveDateTime.utc_now())
      %SocialLogin{provider: provider, uid: uid} = Factory.insert_social_login!(user_id: user_id)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user_by_social_login!({provider, uid})
      end

      assert %User{id: ^user_id} =
               Accounts.get_user_by_social_login!({provider, uid}, include_deactivated: true)
    end
  end

  describe "get_user_count/1" do
    test "with active and deactivated users" do
      active_user_count = 3
      deactivated_user_count = 2
      total_user_count = active_user_count + deactivated_user_count

      Enum.each(1..active_user_count, fn _ ->
        Factory.insert_user!()
      end)

      Enum.each(1..deactivated_user_count, fn _ ->
        Factory.insert_user!(deactivated_at: NaiveDateTime.utc_now())
      end)

      assert Accounts.get_user_count() == active_user_count
      assert Accounts.get_user_count(include_deactivated: true) == total_user_count
    end
  end

  describe "delete_user/1" do
    test "when user exists deletes the user" do
      %User{id: user_id} = user = Factory.insert_user!()

      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert is_nil(Accounts.get_user(user_id))
    end
  end

  describe "delete_user!/1" do
    test "when user exists deletes the user" do
      %User{id: user_id} = user = Factory.insert_user!()

      assert %User{} = Accounts.delete_user!(user)
      assert is_nil(Accounts.get_user(user_id))
    end
  end
end
