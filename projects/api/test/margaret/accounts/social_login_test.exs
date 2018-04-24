defmodule Margaret.SocialLoginTest do
  use Margaret.DataCase

  @valid_attrs %{
    provider: "github",
    uid: ExMachina.sequence(:uid, &"#{&1}")
  }

  describe "changeset/1" do
    test "is valid when the attributes are valid" do
      %User{id: user_id} = Factory.insert(:user)

      attrs = Map.put(@valid_attrs, :user_id, user_id)
      %Changeset{valid?: valid_changeset?} = SocialLogin.changeset(attrs)

      assert valid_changeset?
    end

    test "is invalid when the user_id is nil" do
      attrs = Map.put(@valid_attrs, :user_id, nil)

      %Changeset{valid?: valid_changeset?} = SocialLogin.changeset(attrs)

      refute valid_changeset?
    end

    test "is invalid when required data is missing" do
      attrs = %{}
      %Changeset{valid?: valid_changeset?} = SocialLogin.changeset(attrs)

      refute valid_changeset?
    end
  end
end
