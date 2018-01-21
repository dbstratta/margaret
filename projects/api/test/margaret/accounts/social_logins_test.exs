defmodule Margaret.SocialLoginsTest do
  use Margaret.DataCase

  @valid_attrs %{
    provider: "github",
    uid: "#{System.unique_integer()}"
  }

  describe "changeset/1" do
    test "with valid attributes" do
      %User{id: user_id} = Factory.insert_user!()

      attrs = Map.put(@valid_attrs, :user_id, user_id)
      %Changeset{valid?: changeset_valid?} = SocialLogin.changeset(attrs)

      assert changeset_valid?
    end

    test "with invalid user_id" do
      invalid_user_id = 1
      attrs = Map.put(@valid_attrs, :user_id, invalid_user_id)

      %Changeset{valid?: changeset_valid?} = User.changeset(attrs)

      refute changeset_valid?
    end

    test "when data is not unique" do
      %User{id: user_id} = Factory.insert_user!()
      %SocialLogin{provider: provider, uid: uid} = Factory.insert_social_login!(user_id: user_id)

      attrs = Map.put(%{@valid_attrs | provider: provider, uid: uid}, :user_id, user_id)
      %Changeset{valid?: changeset_valid?} = User.changeset(attrs)

      refute changeset_valid?
    end
  end

  describe "insert_social_login/1" do
    # TODO: Add tests for this.
  end
end
