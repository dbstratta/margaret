defmodule Margaret.FollowsTest do
  use Margaret.DataCase

  describe "changeset/1" do
    test "when following a user with valid attributes" do
      [%User{id: follower_id}, %User{id: user_id}] = Factory.insert_pair(:user)

      attrs = %{follower_id: follower_id, user_id: user_id}
      %Changeset{valid?: valid_changeset?} = Follow.changeset(attrs)

      assert valid_changeset?
    end

    test "when following a publication with valid attributes" do
      %User{id: follower_id} = Factory.insert(:user)
      %Publication{id: publication_id} = Factory.insert(:publication)

      attrs = %{follower_id: follower_id, publication_id: publication_id}
      %Changeset{valid?: valid_changeset?} = Follow.changeset(attrs)

      assert valid_changeset?
    end
  end

  describe "insert_follow/1" do
    test "when following a user with valid attributes" do
      [%User{id: follower_id}, %User{id: user_id}] = Factory.insert_pair(:user)

      attrs = %{follower_id: follower_id, user_id: user_id}

      assert {:ok, %{follow: %Follow{} = follow}} = Follows.insert_follow(attrs)
      assert follow.follower_id == follower_id
      assert follow.user_id == user_id
      refute follow.publication_id
    end

    test "when following a publication with valid attributes succeds" do
      %User{id: follower_id} = Factory.insert(:user)
      %Publication{id: publication_id} = Factory.insert(:publication)

      attrs = %{follower_id: follower_id, publication_id: publication_id}

      assert {:ok, %{follow: %Follow{} = follow}} = Follows.insert_follow(attrs)
      assert follow.follower_id == follower_id
      assert follow.publication_id == publication_id
      refute follow.user_id
    end

    test "when following a user with invalid user_id fails" do
      %User{id: follower_id} = Factory.insert(:user)
      user_id = System.unique_integer([:positive])

      attrs = %{follower_id: follower_id, user_id: user_id}

      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test "when following a user with invalid publication_id fails" do
      %User{id: follower_id} = Factory.insert(:user)
      publication_id = System.unique_integer([:positive])

      attrs = %{follower_id: follower_id, publication_id: publication_id}

      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test "when the follower already follows the user fails" do
      [%User{id: follower_id}, %User{id: user_id}] = Factory.insert_pair(:user)

      attrs = %{follower_id: follower_id, user_id: user_id}
      assert {:ok, _} = Follows.insert_follow(attrs)

      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test "when the follower already follows the publication fails" do
      %User{id: follower_id} = Factory.insert(:user)
      %Publication{id: publication_id} = Factory.insert(:publication)

      attrs = %{follower_id: follower_id, publication_id: publication_id}
      assert {:ok, _} = Follows.insert_follow(attrs)

      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test "when providing user_id and publication_id at the same time fails" do
      [%User{id: follower_id}, %User{id: user_id}] = Factory.insert_pair(:user)
      %Publication{id: publication_id} = Factory.insert(:publication)

      attrs = %{follower_id: follower_id, user_id: user_id, publication_id: publication_id}
      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test "when the follower tries to follow themselves" do
      %User{id: user_id} = Factory.insert(:user)

      attrs = %{follower_id: user_id, user_id: user_id}
      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end
  end

  describe "get_follow/1" do
    test "with valid id returns the follow" do
      [follower, user] = Factory.insert_pair(:user)
      %Follow{id: follow_id} = Factory.insert(:follow, follower: follower, user: user)

      assert %Follow{id: ^follow_id} = Follows.get_follow(follow_id)
    end

    test "with invalid id returns nil" do
      follow_id = System.unique_integer([:positive])

      assert is_nil(Follows.get_follow(follow_id))
    end
  end

  describe "get_followee_count/1" do
    test "when the user has followees" do
      user_followee_count = 3
      publication_followee_count = 1
      total_followee_count = user_followee_count + publication_followee_count

      follower = Factory.insert(:user)

      Enum.each(1..user_followee_count, fn _ ->
        user = Factory.insert(:user)
        Factory.insert(:follow, follower: follower, user: user)
      end)

      Enum.each(1..publication_followee_count, fn _ ->
        publication = Factory.insert(:publication)
        Factory.insert(:follow, follower: follower, publication: publication)
      end)

      assert Follows.get_followee_count(follower) == total_followee_count
    end

    test "when the user has no followees" do
      followee_count = 0

      follower = Factory.insert(:user)

      assert Follows.get_followee_count(follower) == followee_count
    end
  end

  describe "get_follower_count/1" do
    test "when the followee is a user" do
      follower_count = 5

      followee = Factory.insert(:user)

      Enum.each(1..follower_count, fn _ ->
        follower = Factory.insert(:user)
        Factory.insert(:follow, follower: follower, user: followee)
      end)

      assert Follows.get_follower_count(user: followee) == follower_count
    end

    test "when the followee is a publication" do
      follower_count = 5

      followee = Factory.insert(:publication)

      Enum.each(1..follower_count, fn _ ->
        follower = Factory.insert(:user)
        Factory.insert(:follow, follower: follower, publication: followee)
      end)

      assert Follows.get_follower_count(publication: followee) == follower_count
    end
  end

  describe "delete_follow/1" do
    test "when follow exists deletes the follow" do
      [follower, user] = Factory.insert_pair(:user)

      %Follow{id: follow_id} = follow = Factory.insert(:follow, follower: follower, user: user)

      assert {:ok, %Follow{}} = Follows.delete_follow(follow)
      assert is_nil(Follows.get_follow(follow_id))
    end
  end
end
