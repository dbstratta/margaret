defmodule Margaret.FollowTest do
  use Margaret.DataCase

  describe "changeset/1" do
    test "is valid when the followee is a user and the attributes are valid" do
      [%User{id: follower_id}, %User{id: user_id}] = Factory.insert_pair(:user)

      attrs = %{follower_id: follower_id, user_id: user_id}
      %Changeset{valid?: valid_changeset?} = Follow.changeset(attrs)

      assert valid_changeset?
    end

    test "is valid when the followee is a publication and the attributes are valid" do
      %User{id: follower_id} = Factory.insert(:user)
      %Publication{id: publication_id} = publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      attrs = %{follower_id: follower_id, publication_id: publication_id}
      %Changeset{valid?: valid_changeset?} = Follow.changeset(attrs)

      assert valid_changeset?
    end

    test "is invalid when data is missing" do
      %Publication{id: publication_id} = publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      attrs = %{publication_id: publication_id}
      %Changeset{valid?: valid_changeset?} = Follow.changeset(attrs)

      refute valid_changeset?
    end
  end
end
