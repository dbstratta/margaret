defmodule Margaret.StoryTest do
  use Margaret.DataCase

  @valid_attrs %{
    content: %{"blocks" => [%{"text" => "test"}]},
    audience: :all,
    published_at: nil,
    license: :all_rights_reserved
  }

  describe "changeset/1" do
    test "is valid when the attributes are valid" do
      author = Factory.insert(:user)

      attrs =
        @valid_attrs
        |> Map.put(:author_id, author.id)

      %Changeset{valid?: valid_changeset?} = Story.changeset(attrs)

      assert valid_changeset?
    end

    test "is invalid when the attributes are invalid" do
      %Changeset{valid?: valid_changeset?} = Story.changeset(@valid_attrs)

      refute valid_changeset?
    end

    test "puts the unique_hash in data" do
      author = Factory.insert(:user)

      attrs =
        @valid_attrs
        |> Map.put(:author_id, author.id)

      changeset = Story.changeset(attrs)

      assert {:ok, unique_hash} = fetch_change(changeset, :unique_hash)
      assert is_binary(unique_hash)
    end
  end

  describe "update_changeset/2" do
    test "is valid when the attributes are valid" do
      story = Factory.insert(:story)

      %Changeset{valid?: valid_changeset?} = Story.update_changeset(story, @valid_attrs)

      assert valid_changeset?
    end

    test "is invalid when the attributes are invalid" do
      story = Factory.insert(:story)

      attrs =
        @valid_attrs
        |> Map.put(:license, :nonexistent_license)

      %Changeset{valid?: valid_changeset?} = Story.update_changeset(story, attrs)

      refute valid_changeset?
    end
  end

  describe "published/1" do
    test "matches only published stories" do
      published_story_count = 2
      Factory.insert_list(published_story_count, :story, published_at: NaiveDateTime.utc_now())

      not_published_story_count = 4
      Factory.insert_list(not_published_story_count, :story, published_at: nil)

      scheduled_story_count = 8
      seconds_from_now = 60 * 60 * 24 * 365 * 2
      scheduled_naive_datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(seconds_from_now)
      Factory.insert_list(scheduled_story_count, :story, published_at: scheduled_naive_datetime)

      query = Story.published()

      assert Repo.count(query) === published_story_count
    end
  end

  describe "scheduled/1" do
    test "matches only scheduled stories" do
      published_story_count = 2
      Factory.insert_list(published_story_count, :story, published_at: NaiveDateTime.utc_now())

      not_published_story_count = 4
      Factory.insert_list(not_published_story_count, :story, published_at: nil)

      scheduled_story_count = 8
      seconds_from_now = 60 * 60 * 24 * 365 * 2
      scheduled_naive_datetime = NaiveDateTime.utc_now() |> NaiveDateTime.add(seconds_from_now)
      Factory.insert_list(scheduled_story_count, :story, published_at: scheduled_naive_datetime)

      query = Story.scheduled()

      assert Repo.count(query) === scheduled_story_count
    end
  end

  describe "public/1" do
    test "matches only public stories" do
      public_story_count = 2

      Factory.insert_list(
        public_story_count,
        :story,
        audience: :all,
        published_at: NaiveDateTime.utc_now()
      )

      not_public_story_count = 4
      Factory.insert_list(not_public_story_count, :story, audience: :unlisted)

      query = Story.public()

      assert Repo.count(query) === public_story_count
    end
  end

  describe "by_author/2" do
    test "matches only stories by the author" do
      Factory.insert_list(2, :story)

      author = Factory.insert(:user)

      story_count = 4
      Factory.insert_list(story_count, :story, author: author)

      query = Story.by_author(author)

      assert Repo.count(query) === story_count
    end
  end

  describe "under_publication/2" do
    test "matches only stories under the publication" do
      Factory.insert_list(2, :story)

      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      story_count = 4
      Factory.insert_list(story_count, :story, publication: publication)

      query = Story.under_publication(publication)

      assert Repo.count(query) === story_count
    end
  end
end
