defmodule Margaret.FollowsTest do
  use Margaret.DataCase

  describe "changeset/1" do
    test "when following a user with valid attributes" do
      %User{id: follower_id} = Factory.insert_user!()
      %User{id: user_id} = Factory.insert_user!()

      attrs = %{follower_id: follower_id, user_id: user_id}
      %Changeset{valid?: changeset_valid?} = Follow.changeset(attrs)

      assert changeset_valid?
    end

    test "when following a publication with valid attributes" do
      %User{id: follower_id} = Factory.insert_user!()
      %Publication{id: publication_id} = Factory.insert_publication!()

      attrs = %{follower_id: follower_id, publication_id: publication_id}
      %Changeset{valid?: changeset_valid?} = Follow.changeset(attrs)

      assert changeset_valid?
    end
  end
end
