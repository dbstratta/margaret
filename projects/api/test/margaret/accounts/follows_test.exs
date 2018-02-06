defmodule Margaret.FollowsTest do
  use Margaret.DataCase

  describe "changeset/1" do
    test "when following a user with valid attributes" do
      [%User{id: follower_id}, %User{id: user_id}] = Factory.insert_pair(:user)

      attrs = %{follower_id: follower_id, user_id: user_id}
      %Changeset{valid?: changeset_valid?} = Follow.changeset(attrs)

      assert changeset_valid?
    end

    test "when following a publication with valid attributes" do
      %User{id: follower_id} = Factory.insert(:user)
      %Publication{id: publication_id} = Factory.insert(:publication)

      attrs = %{follower_id: follower_id, publication_id: publication_id}
      %Changeset{valid?: changeset_valid?} = Follow.changeset(attrs)

      assert changeset_valid?
    end
  end

  describe "insert_follow/1" do
    test "when following a user with valid attributes" do
      %User{id: follower_id} = Factory.insert_user!()
      %User{id: user_id} = Factory.insert_user!()

      attrs = %{follower_id: follower_id, user_id: user_id}

      assert {:ok, %{follow: %Follow{} = follow}} = Accounts.insert_follow(attrs)
      assert follow.follower_id == follower_id
      assert follow.user_id == user_id
      refute follow.publication_id
    end

    test "when following a publication with valid attributes succeds" do
      %User{id: follower_id} = Factory.insert_user!()
      %Publication{id: publication_id} = Factory.insert_publication!()

      attrs = %{follower_id: follower_id, publication_id: publication_id}

      assert {:ok, %{follow: %Follow{} = follow}} = Accounts.insert_follow(attrs)
      assert follow.follower_id == follower_id
      assert follow.publication_id == publication_id
      refute follow.user_id
    end

    test "when following a user with invalid user_id fails" do
      %User{id: follower_id} = Factory.insert_user!()
      user_id = System.unique_integer([:positive])

      attrs = %{follower_id: follower_id, user_id: user_id}

      assert {:error, _, _, _} = Accounts.insert_follow(attrs)
    end

    test "when following a user with invalid publication_id fails" do
      %User{id: follower_id} = Factory.insert_user!()
      publication_id = System.unique_integer([:positive])

      attrs = %{follower_id: follower_id, publication_id: publication_id}

      assert {:error, _, _, _} = Accounts.insert_follow(attrs)
    end

    test "when the follower already follows the user fails" do
      %User{id: follower_id} = Factory.insert_user!()
      %User{id: user_id} = Factory.insert_user!()

      attrs = %{follower_id: follower_id, user_id: user_id}
      assert {:ok, _} = Accounts.insert_follow(attrs)

      assert {:error, _, _, _} = Accounts.insert_follow(attrs)
    end

    test "when the follower already follows the publication fails" do
      %User{id: follower_id} = Factory.insert_user!()
      %Publication{id: publication_id} = Factory.insert_publication!()

      attrs = %{follower_id: follower_id, publication_id: publication_id}
      assert {:ok, _} = Accounts.insert_follow(attrs)

      assert {:error, _, _, _} = Accounts.insert_follow(attrs)
    end

    test "when providing user_id and publication_id at the same time fails" do
      %User{id: follower_id} = Factory.insert_user!()
      %User{id: user_id} = Factory.insert_user!()
      %Publication{id: publication_id} = Factory.insert_publication!()

      attrs = %{follower_id: follower_id, user_id: user_id, publication_id: publication_id}
      assert {:error, _, _, _} = Accounts.insert_follow(attrs)
    end

    test "when the follower tries to follow themselves" do
      %User{id: user_id} = Factory.insert_user!()

      attrs = %{follower_id: user_id, user_id: user_id}
      assert {:error, _, _, _} = Accounts.insert_follow(attrs)
    end
  end

  describe "get_follow/1" do
    test "with valid id returns the follow" do
      %User{id: follower_id} = Factory.insert_user!()
      %User{id: user_id} = Factory.insert_user!()
      %Follow{id: follow_id} = Factory.insert_follow!(follower_id: follower_id, user_id: user_id)

      assert %Follow{id: ^follow_id} = Accounts.get_follow(follow_id)
    end

    test "with invalid id returns nil" do
      follow_id = System.unique_integer([:positive])

      assert is_nil(Accounts.get_follow(follow_id))
    end
  end

  describe "get_followee_count/1" do
    test "when the user has followees" do
      user_followee_count = 3
      publication_followee_count = 1
      total_followee_count = user_followee_count + publication_followee_count

      %User{id: follower_id} = Factory.insert_user!()

      Enum.each(1..user_followee_count, fn _ ->
        %User{id: user_id} = Factory.insert_user!()
        Factory.insert_follow!(follower_id: follower_id, user_id: user_id)
      end)

      Enum.each(1..publication_followee_count, fn _ ->
        %Publication{id: publication_id} = Factory.insert_publication!()
        Factory.insert_follow!(follower_id: follower_id, publication_id: publication_id)
      end)

      assert Accounts.get_followee_count(follower_id) == total_followee_count
    end

    test "when the user has no followees" do
      followee_count = 0

      %User{id: follower_id} = Factory.insert_user!()

      assert Accounts.get_followee_count(follower_id) == followee_count
    end
  end

  describe "get_follower_count/1" do
    test "when the followee is a user" do
      follower_count = 5

      %User{id: followee_id} = Factory.insert_user!()

      Enum.each(1..follower_count, fn _ ->
        %User{id: follower_id} = Factory.insert_user!()
        Factory.insert_follow!(follower_id: follower_id, user_id: followee_id)
      end)

      assert Accounts.get_follower_count(%{user_id: followee_id}) == follower_count
    end

    test "when the followee is a publication" do
      follower_count = 5

      %Publication{id: followee_id} = Factory.insert_publication!()

      Enum.each(1..follower_count, fn _ ->
        %User{id: follower_id} = Factory.insert_user!()
        Factory.insert_follow!(follower_id: follower_id, publication_id: followee_id)
      end)

      assert Accounts.get_follower_count(%{publication_id: followee_id}) == follower_count
    end
  end

  describe "delete_follow/1" do
    test "when follow exists deletes the follow" do
      %User{id: follower_id} = Factory.insert_user!()
      %User{id: user_id} = Factory.insert_user!()

      %Follow{id: follow_id} =
        follow = Factory.insert_follow!(follower_id: follower_id, user_id: user_id)

      assert {:ok, %Follow{}} = Accounts.delete_follow(follow)
      assert is_nil(Accounts.get_follow(follow_id))
    end
  end
end
