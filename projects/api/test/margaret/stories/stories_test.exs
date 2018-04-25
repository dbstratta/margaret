defmodule Margaret.StoriesTest do
  use Margaret.DataCase

  @valid_attrs %{
    content: %{"blocks" => [%{"text" => "test"}]},
    audience: :all,
    published_at: nil,
    license: :all_rights_reserved
  }

  describe "get_story/1" do
    test "returns the story when there's a story with that id" do
      %Story{id: story_id} = Factory.insert(:story)

      assert %Story{id: ^story_id} = Stories.get_story(story_id)
    end

    test "returns nil when there isn't a story with that id" do
      story_id = 1

      assert is_nil(Stories.get_story(story_id))
    end
  end

  describe "get_story!/1" do
    test "returns the story when there's a story with that id" do
      %Story{id: story_id} = Factory.insert(:story)

      assert %Story{id: ^story_id} = Stories.get_story!(story_id)
    end

    test "returns nil when there isn't a story with that id" do
      story_id = 1

      assert_raise Ecto.NoResultsError, fn ->
        Stories.get_story!(story_id)
      end
    end
  end

  describe "get_story_by_slug/1" do
    test "returns the story when there's a story with that slug" do
      %Story{id: story_id, unique_hash: unique_hash} = Factory.insert(:story)

      slug = "test-" <> unique_hash

      assert %Story{id: ^story_id} = Stories.get_story_by_slug(slug)
    end

    test "returns nil when there isn't a story with that slug" do
      slug = "test-abc123"

      assert is_nil(Stories.get_story_by_slug(slug))
    end
  end

  describe "title/1" do
    test "returns the title of a story" do
      title = "Title"

      story = Factory.insert(:story, content: %{"blocks" => [%{"text" => title}]})

      assert title === Stories.title(story)
    end
  end

  describe "slug/1" do
    test "returns the slug of a story" do
      story = %Story{unique_hash: unique_hash} = Factory.insert(:story)

      assert String.contains?(Stories.slug(story), unique_hash)
    end
  end

  describe "author/1" do
    test "returns the author of a story" do
      story = %Story{author_id: author_id} = Factory.insert(:story)

      assert %User{} = author = Accounts.get_user(author_id)

      assert author.id === Stories.author(story).id
    end
  end

  describe "tags/1" do
    test "returns the tags of a story" do
      tags =
        ["test", "story", "elixir"]
        |> Enum.map(&%Tag{title: &1})

      story = Factory.insert(:story, tags: tags)
      actual_tag_titles = Enum.map(story.tags, & &1.title)

      assert Enum.all?(tags, &(&1.title in actual_tag_titles))
    end
  end

  describe "publication/1" do
    test "returns the publication of the story when the story is under a publication" do
      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)
      story = Factory.insert(:story, publication: publication)

      assert Stories.publication(story).id === publication.id
    end

    test "returns nil when the story is not under a publication" do
      story = Factory.insert(:story, publication: nil)

      assert is_nil(Stories.publication(story))
    end
  end

  describe "collection/1" do
    test "returns the collection of a story when the story is in a collection" do
      story = Factory.insert(:story)

      %CollectionStory{collection_id: collection_id} =
        Factory.insert(:collection_story, story: story, part: 1)

      assert Stories.collection(story).id === collection_id
    end

    test "returns nil when the story isn't in a collection" do
      story = Factory.insert(:story)

      assert is_nil(Stories.collection(story))
    end
  end

  describe "notifiable_users_of_new_story/1" do
    test """
    returns the list of users that will be notified when the story is published
    and the story isn't under a publication
    """ do
      author = Factory.insert(:user)
      story = Factory.insert(:story, author: author)

      author_follower_count = 3
      author_followers = Factory.insert_list(author_follower_count, :user)

      Enum.each(author_followers, fn author_follower ->
        Factory.insert(:follow, follower: author_follower, user: author)
      end)

      notifiable_user_ids =
        story
        |> Stories.notifiable_users_of_new_story()
        |> Enum.map(& &1.id)

      assert length(notifiable_user_ids) === length(author_followers)

      Enum.each(author_followers, &assert(&1.id in notifiable_user_ids))
    end

    test "returns an empty list when there are no notifiable users" do
      story = Factory.insert(:story)

      notifiable_users = Stories.notifiable_users_of_new_story(story)

      assert Enum.empty?(notifiable_users)
    end

    test """
    returns the list of users that will be notified when the story is published
    and the story is under a publication
    """ do
      author = Factory.insert(:user)
      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)
      story = Factory.insert(:story, author: author, publication: publication)

      author_follower_count = 3
      author_followers = Factory.insert_list(author_follower_count, :user)

      Enum.each(author_followers, fn author_follower ->
        Factory.insert(:follow, follower: author_follower, user: author)
      end)

      publication_follower_count = 5
      publication_followers = Factory.insert_list(publication_follower_count, :user)

      Enum.each(publication_followers, fn publication_follower ->
        Factory.insert(:follow, follower: publication_follower, publication: publication)
      end)

      followers = author_followers ++ publication_followers

      notifiable_user_ids =
        story
        |> Stories.notifiable_users_of_new_story()
        |> Enum.map(& &1.id)

      assert length(notifiable_user_ids) === length(followers)

      Enum.each(followers, &assert(&1.id in notifiable_user_ids))
    end
  end

  describe "story_count/1" do
    test "returns the total count of stories" do
      story_count = 10
      Factory.insert_list(story_count, :story, published_at: NaiveDateTime.utc_now())

      assert Stories.story_count() === story_count
    end

    test "includes not published stories by default" do
      not_published_story_count = 6
      Factory.insert_list(not_published_story_count, :story, published_at: nil)

      assert Stories.story_count() === not_published_story_count
    end

    test "includes only published stories when published_only is true" do
      published_story_count = 10
      Factory.insert_list(published_story_count, :story, published_at: NaiveDateTime.utc_now())

      not_published_story_count = 6
      Factory.insert_list(not_published_story_count, :story, published_at: nil)

      assert Stories.story_count(published_only: true) === published_story_count
    end
  end

  describe "under_publication?/1" do
    test "returns true when the story is under a publication" do
      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      story = Factory.insert(:story, publication: publication)

      assert Stories.under_publication?(story)
    end

    test "returns false when the story isn't under a publication" do
      story = Factory.insert(:story)

      refute Stories.under_publication?(story)
    end
  end

  describe "in_collection?/1" do
    test "returns true when the story is in a collection" do
      story = Factory.insert(:story)

      Factory.insert(:collection_story, story: story, part: 1)

      assert Stories.in_collection?(story)
    end

    test "returns false when the story isn't in a collection" do
      story = Factory.insert(:story)

      refute Stories.in_collection?(story)
    end
  end

  describe "has_been_published?/1" do
    test "returns true when the story has been published" do
      story = Factory.insert(:story, published_at: NaiveDateTime.utc_now())

      assert Stories.has_been_published?(story)
    end

    test "returns false when the story hasn't been published" do
      story = Factory.insert(:story, published_at: nil)

      refute Stories.has_been_published?(story)
    end
  end

  describe "public?/1" do
    test "returns true when the story is public" do
      story = Factory.insert(:story, published_at: NaiveDateTime.utc_now(), audience: :all)

      assert Stories.public?(story)
    end

    test "returns false when the story isn't public" do
      story = Factory.insert(:story, published_at: nil, audience: :all)
      refute Stories.public?(story)

      story2 = Factory.insert(:story, published_at: NaiveDateTime.utc_now(), audience: :unlisted)
      refute Stories.public?(story2)
    end
  end

  describe "can_see_story?/2" do
    test "returns true when the user is the author of the story" do
      user = Factory.insert(:user)
      story = Factory.insert(:story, author: user)

      assert Stories.can_see_story?(story, user)
    end

    test """
    returns true when the story is in a publication and
    the user is an editor, admin, or owner of that publication
    """ do
      publication_editor = Factory.insert(:user)
      publication_admin = Factory.insert(:user)
      publication_owner = Factory.insert(:user)

      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: publication_owner,
        role: :owner
      )

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: publication_editor,
        role: :editor
      )

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: publication_admin,
        role: :admin
      )

      story = Factory.insert(:story, publication: publication, published_at: nil)

      assert Stories.can_see_story?(story, publication_owner)
      assert Stories.can_see_story?(story, publication_admin)
      assert Stories.can_see_story?(story, publication_editor)
    end

    test "returns false when the user is a regular user the story hasn't been published" do
      user = Factory.insert(:user)
      story = Factory.insert(:story, published_at: nil)

      refute Stories.can_see_story?(story, user)
    end

    test "returns false when the user is a regular user and the story isn't public" do
      user = Factory.insert(:user)
      story = Factory.insert(:story, published_at: NaiveDateTime.utc_now(), audience: :unlisted)

      refute Stories.can_see_story?(story, user)
    end
  end

  describe "insert_story/1" do
    test "inserts a story when the attributes are valid" do
      %User{id: author_id} = Factory.insert(:user)

      attrs = Map.put(@valid_attrs, :author_id, author_id)
      assert {:ok, %{story: %Story{id: story_id}}} = Stories.insert_story(attrs)

      assert %Story{id: ^story_id} = Stories.get_story!(story_id)
    end

    test "doesn't insert a story when the attributes are invalid" do
      %User{id: author_id} = Factory.insert(:user)

      invalid_attrs =
        @valid_attrs
        |> Map.put(:author_id, author_id)
        |> Map.put(:audience, :bad_attr)

      assert {:error, _, _, _} = Stories.insert_story(invalid_attrs)
    end

    test "inserts the tags if they don't exist already" do
      %User{id: author_id} = Factory.insert(:user)
      tag_titles = ["test", "elixir", "phoenix", "margaret"]

      attrs =
        @valid_attrs
        |> Map.put(:tags, tag_titles)
        |> Map.put(:author_id, author_id)

      assert {:ok, _} = Stories.insert_story(attrs)

      Enum.each(tag_titles, fn tag_title ->
        assert %Tag{title: ^tag_title} = Tags.get_tag_by_title(tag_title)
      end)
    end

    test "inserts the story in a collection when collection_id is provided" do
      %User{} = author = Factory.insert(:user)

      %Collection{id: collection_id} = Factory.insert(:collection, author: author)

      attrs =
        @valid_attrs
        |> Map.put(:author_id, author.id)
        |> Map.put(:collection_id, collection_id)

      assert {:ok, %{story: %Story{} = story}} = Stories.insert_story(attrs)

      assert Stories.in_collection?(story)
      assert Stories.collection(story).id === collection_id
    end

    test "inserts the story under a publication when publication_id is provided" do
      author = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: author,
        role: :owner
      )

      attrs =
        @valid_attrs
        |> Map.put(:author_id, author.id)
        |> Map.put(:publication_id, publication.id)

      assert {:ok, %{story: %Story{} = story}} = Stories.insert_story(attrs)

      assert Stories.under_publication?(story)
      assert Stories.publication(story).id === publication.id
    end

    test """
    inserts notifications of new story when the story is published and
    the story isn't under a publication
    """ do
      author = Factory.insert(:user)

      author_follower_count = 3
      author_followers = Factory.insert_list(author_follower_count, :user)

      Enum.each(author_followers, fn author_follower ->
        Factory.insert(:follow, follower: author_follower, user: author)
      end)

      attrs =
        @valid_attrs
        |> Map.put(:author_id, author.id)
        |> Map.put(:published_at, NaiveDateTime.utc_now())

      assert {:ok, %{story: %Story{} = story}} = Stories.insert_story(attrs)

      assert %Notification{id: notification_id} =
               Notifications.get_notification_by(
                 action: :added,
                 actor_id: author.id,
                 story_id: story.id
               )

      Enum.each(author_followers, fn author_follower ->
        assert %UserNotification{} =
                 Notifications.get_user_notification(
                   user_id: author_follower.id,
                   notification_id: notification_id
                 )
      end)
    end

    test """
    inserts notifications of new story when the story is published and
    the story is under a publication
    """ do
      author = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: author,
        role: :owner
      )

      author_follower_count = 3
      author_followers = Factory.insert_list(author_follower_count, :user)

      Enum.each(author_followers, fn author_follower ->
        Factory.insert(:follow, follower: author_follower, user: author)
      end)

      publication_follower_count = 5
      publication_followers = Factory.insert_list(publication_follower_count, :user)

      Enum.each(publication_followers, fn publication_follower ->
        Factory.insert(:follow, follower: publication_follower, publication: publication)
      end)

      followers = author_followers ++ publication_followers

      attrs =
        @valid_attrs
        |> Map.put(:author_id, author.id)
        |> Map.put(:publication_id, publication.id)
        |> Map.put(:published_at, NaiveDateTime.utc_now())

      assert {:ok, %{story: %Story{} = story}} = Stories.insert_story(attrs)

      assert %Notification{id: notification_id} =
               Notifications.get_notification_by(
                 action: :added,
                 actor_id: author.id,
                 story_id: story.id
               )

      Enum.each(followers, fn follower ->
        assert %UserNotification{} =
                 Notifications.get_user_notification(
                   user_id: follower.id,
                   notification_id: notification_id
                 )
      end)
    end

    test "doesn't insert notifications of new story when the story isn't published" do
      author = Factory.insert(:user)

      author_follower_count = 3
      author_followers = Factory.insert_list(author_follower_count, :user)

      Enum.each(author_followers, fn author_follower ->
        Factory.insert(:follow, follower: author_follower, user: author)
      end)

      attrs =
        @valid_attrs
        |> Map.put(:author_id, author.id)

      assert {:ok, %{story: %Story{} = story}} = Stories.insert_story(attrs)

      assert is_nil(
               Notifications.get_notification_by(
                 action: :added,
                 actor_id: author.id,
                 story_id: story.id
               )
             )
    end

    test """
    doesn't insert the story when the author doesn't have permission
    to add stories under the publication
    """ do
      author = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        role: :owner
      )

      attrs =
        @valid_attrs
        |> Map.put(:author_id, author.id)
        |> Map.put(:publication_id, publication.id)

      assert {:error, _, _, _} = Stories.insert_story(attrs)
    end
  end
end
