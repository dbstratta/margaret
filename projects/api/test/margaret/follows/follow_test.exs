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

  describe "by_follower/2" do
    test "matches the followees of the follower" do
      follower = Factory.insert(:user)

      user_count = 3
      publication_count = 2
      followee_count = user_count + publication_count

      Enum.each(1..user_count, fn _ ->
        user = Factory.insert(:user)
        Factory.insert(:follow, follower: follower, user: user)
      end)

      Enum.each(1..publication_count, fn _ ->
        publication = Factory.insert(:publication)
        Factory.insert(:publication_membership, publication: publication, role: :owner)
        Factory.insert(:follow, follower: follower, publication: publication)
      end)

      query = Follow.by_follower(follower)
      actual_followee_count = Repo.count(query)

      assert actual_followee_count === followee_count
    end

    test "doesn't match anything when the user doesn't follow anything" do
      follower = Factory.insert(:user)

      followee_count = 0

      query = Follow.by_follower(follower)
      actual_followee_count = Repo.count(query)

      assert actual_followee_count === followee_count
    end
  end
end
