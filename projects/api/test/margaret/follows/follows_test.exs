defmodule Margaret.FollowsTest do
  use Margaret.DataCase

  describe "insert_follow/1" do
    test "inserts a follow when the followee is a user and the attributes are valid" do
      [%User{id: follower_id}, %User{id: user_id}] = Factory.insert_pair(:user)

      attrs = %{follower_id: follower_id, user_id: user_id}

      assert {:ok, %{follow: %Follow{} = follow}} = Follows.insert_follow(attrs)
      assert follow.follower_id === follower_id
      assert follow.user_id === user_id
      assert is_nil(follow.publication_id)
    end

    test "inserts a follow when the followee is a publication and the attributes are valid" do
      %User{id: follower_id} = Factory.insert(:user)
      %Publication{id: publication_id} = publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      attrs = %{follower_id: follower_id, publication_id: publication_id}

      assert {:ok, %{follow: %Follow{} = follow}} = Follows.insert_follow(attrs)
      assert follow.follower_id === follower_id
      assert follow.publication_id === publication_id
      assert is_nil(follow.user_id)
    end

    test "doesn't insert a follow when the followee is a user and the user_id is invalid" do
      %User{id: follower_id} = Factory.insert(:user)
      user_id = 1

      attrs = %{follower_id: follower_id, user_id: user_id}

      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test """
    doesn't insert a follow when the followee is a publication and
    the publication_id is invalid
    """ do
      %User{id: follower_id} = Factory.insert(:user)
      publication_id = 1

      attrs = %{follower_id: follower_id, publication_id: publication_id}

      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test """
    doesn't insert a follow when the followee is a user and
    the follower already follows the followee
    """ do
      [%User{id: follower_id}, %User{id: user_id}] = Factory.insert_pair(:user)

      attrs = %{follower_id: follower_id, user_id: user_id}
      assert {:ok, _} = Follows.insert_follow(attrs)

      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test """
    doesn't insert a follow when the followee is a publication and
    the follower already follows the followee
    """ do
      %User{id: follower_id} = Factory.insert(:user)
      %Publication{id: publication_id} = publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      attrs = %{follower_id: follower_id, publication_id: publication_id}
      assert {:ok, _} = Follows.insert_follow(attrs)

      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test "doesn't insert a follow when providing both a publication_id and a user_id" do
      [%User{id: follower_id}, %User{id: user_id}] = Factory.insert_pair(:user)
      %Publication{id: publication_id} = publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      attrs = %{follower_id: follower_id, user_id: user_id, publication_id: publication_id}
      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end

    test "doesn't insert a follow when the follower is the same user as the followee" do
      %User{id: user_id} = Factory.insert(:user)

      attrs = %{follower_id: user_id, user_id: user_id}
      assert {:error, _, _, _} = Follows.insert_follow(attrs)
    end
  end

  describe "get_follow/1" do
    test "returns the follow when there is a follow with that id" do
      [follower, user] = Factory.insert_pair(:user)
      %Follow{id: follow_id} = Factory.insert(:follow, follower: follower, user: user)

      assert %Follow{id: ^follow_id} = Follows.get_follow(follow_id)
    end

    test "returns nil when there isn't a follow with that id" do
      follow_id = 1

      assert is_nil(Follows.get_follow(follow_id))
    end
  end

  describe "followee_count/1" do
    test "returns the followee count of a user" do
      user_count = 3
      publication_count = 1
      followee_count = user_count + publication_count

      follower = Factory.insert(:user)

      Enum.each(1..user_count, fn _ ->
        user = Factory.insert(:user)
        Factory.insert(:follow, follower: follower, user: user)
      end)

      Enum.each(1..publication_count, fn _ ->
        publication = Factory.insert(:publication)
        Factory.insert(:publication_membership, publication: publication, role: :owner)
        Factory.insert(:follow, follower: follower, publication: publication)
      end)

      actual_followee_count = Follows.followee_count(follower)

      assert actual_followee_count === followee_count
    end

    test "returns 0 when the user doesn't follow anything" do
      followee_count = 0

      follower = Factory.insert(:user)

      actual_followee_count = Follows.followee_count(follower)

      assert actual_followee_count === followee_count
    end
  end

  describe "follower_count/1" do
    test "returns the follower count when the followee is a user" do
      follower_count = 5
      user = Factory.insert(:user)

      Factory.insert_list(follower_count, :follow, user: user)

      actual_follower_count = Follows.follower_count(user: user)

      assert actual_follower_count === follower_count
    end

    test "returns the follower count when the followee is a publication" do
      follower_count = 5
      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      Factory.insert_list(follower_count, :follow, publication: publication)

      actual_follower_count = Follows.follower_count(publication: publication)

      assert actual_follower_count === follower_count
    end
  end

  describe "followable/1" do
    test "returns the followable of a follow when the followable is a user" do
      user = Factory.insert(:user)
      follow = Factory.insert(:follow, user: user)

      assert Follows.followable(follow) === user
    end

    test "returns the followable of a follow when the followable is a publication" do
      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)
      follow = Factory.insert(:follow, publication: publication)

      assert Follows.followable(follow) === publication
    end
  end

  describe "has_followed?/1" do
    test "returns true when the user has followed a user" do
      [follower, user] = Factory.insert_pair(:user)
      Factory.insert(:follow, follower: follower, user: user)

      assert Follows.has_followed?(follower: follower, user: user)
    end

    test "returns false when the user hasn't followed a user" do
      [follower, user] = Factory.insert_pair(:user)

      refute Follows.has_followed?(follower: follower, user: user)
    end

    test "returns true when the user has followed a publication" do
      follower = Factory.insert(:user)
      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      Factory.insert(:follow, follower: follower, publication: publication)

      assert Follows.has_followed?(follower: follower, publication: publication)
    end

    test "returns false when the user hasn't followed a publication" do
      follower = Factory.insert(:user)
      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      refute Follows.has_followed?(follower: follower, publication: publication)
    end
  end

  describe "can_follow?/1" do
    test "returns true when the follower isn't the same as the followee" do
      [follower, user] = Factory.insert_pair(:user)

      assert Follows.can_follow?(follower: follower, user: user)
    end

    test "returns false when the follower is the same as the followee" do
      follower = Factory.insert(:user)

      refute Follows.can_follow?(follower: follower, user: follower)
    end
  end

  describe "delete_follow/1" do
    test "deletes the follow when the follow exists" do
      [follower, user] = Factory.insert_pair(:user)

      %Follow{id: follow_id} = follow = Factory.insert(:follow, follower: follower, user: user)

      assert {:ok, %Follow{}} = Follows.delete_follow(follow)
      assert is_nil(Follows.get_follow(follow_id))
    end
  end
end
