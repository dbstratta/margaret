defmodule Margaret.SocialLoginsTest do
  use Margaret.DataCase

  @valid_attrs %{
    provider: "github",
    uid: "#{System.unique_integer()}"
  }

  describe "changeset/1" do
    test "with valid attributes" do
      %User{id: user_id} = Factory.insert(:user)

      attrs = Map.put(@valid_attrs, :user_id, user_id)
      %Changeset{valid?: valid_changeset?} = SocialLogin.changeset(attrs)

      assert valid_changeset?
    end

    test "with invalid user_id" do
      invalid_user_id = 1
      attrs = Map.put(@valid_attrs, :user_id, invalid_user_id)

      %Changeset{valid?: valid_changeset?} = User.changeset(attrs)

      refute valid_changeset?
    end

    test "when data is not unique" do
      %User{id: user_id} = user = Factory.insert(:user)
      %SocialLogin{provider: provider, uid: uid} = Factory.insert(:social_login, user: user)

      attrs = Map.put(%{@valid_attrs | provider: provider, uid: uid}, :user_id, user_id)
      %Changeset{valid?: valid_changeset?} = User.changeset(attrs)

      refute valid_changeset?
    end
  end

  describe "insert_social_login/1" do
    # TODO: Add tests for this.
  end
end
