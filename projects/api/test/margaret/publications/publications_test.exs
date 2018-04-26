defmodule Margaret.PublicationsTest do
  use Margaret.DataCase

  @valid_attrs %{
    name: "test-publication",
    display_name: "Test Publication",
    description: "Test publication.",
    website: "https://example.com"
  }

  describe "get_publication/1" do
    test "returns the publication when there's a publication with that id" do
      %Publication{id: publication_id} = Factory.insert(:publication)

      assert %Publication{id: ^publication_id} = Publications.get_publication(publication_id)
    end

    test "returns nil when there isn't a publication with that id" do
      publication_id = 1

      assert is_nil(Publications.get_publication(publication_id))
    end
  end

  describe "get_publication_by_name/1" do
    test "returns the publication when there's a publication with that name" do
      %Publication{name: publication_name} = Factory.insert(:publication)

      assert %Publication{name: ^publication_name} =
               Publications.get_publication_by_name(publication_name)
    end

    test "returns nil when there isn't a publication with that name" do
      publication_name = "test"

      assert is_nil(Publications.get_publication_by_name(publication_name))
    end
  end

  describe "tags/1" do
    test "returns the tags of a publication" do
      tags =
        ["test", "publication", "elixir"]
        |> Enum.map(&%Tag{title: &1})

      publication = Factory.insert(:publication, tags: tags)
      actual_tag_titles = Enum.map(publication.tags, & &1.title)

      assert Enum.all?(tags, &(&1.title in actual_tag_titles))
    end
  end

  describe "member_role/2" do
    test "returns the role of the user when the user is a member of the publication" do
      user = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: user,
        role: :owner
      )

      assert Publications.member_role(publication, user) === :owner
    end

    test "returns nil when the user isn't a member of the publication" do
      user = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(:publication_membership, publication: publication, role: :owner)

      assert is_nil(Publications.member_role(publication, user))
    end
  end

  describe "member_count/1" do
    test "returns the member count of the publication" do
      Factory.insert_list(2, :user)

      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      writer_count = 4
      member_count = writer_count + 1

      Factory.insert_list(
        writer_count,
        :publication_membership,
        publication: publication,
        role: :writer
      )

      assert Publications.member_count(publication) === member_count
    end
  end

  describe "story_count/1" do
    test "returns the story count of the publication" do
      Factory.insert_list(2, :story)

      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      not_published_story_count = 4

      Factory.insert_list(
        not_published_story_count,
        :story,
        publication: publication,
        published_at: nil
      )

      story_count = 4

      Factory.insert_list(
        story_count,
        :story,
        publication: publication,
        published_at: NaiveDateTime.utc_now()
      )

      assert Publications.story_count(publication) === story_count
    end
  end

  describe "check_role/3" do
    test "returns true when the user has a permitted role in the publication" do
      user = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: user,
        role: :owner
      )

      assert Publications.check_role(publication, user, :owner)
      assert Publications.check_role(publication, user, [:owner])
      assert Publications.check_role(publication, user, [:owner, :editor])
    end

    test "returns false when the user doesn't have a permitted role in the publication" do
      user = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: user,
        role: :owner
      )

      refute Publications.check_role(publication, user, :writer)
      refute Publications.check_role(publication, user, [:writer])
      refute Publications.check_role(publication, user, [:writer, :editor])
    end
  end

  describe "member?/2" do
    test "returns true when the user is a member of the publication" do
      user = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: user,
        role: :owner
      )

      assert Publications.member?(publication, user)
    end

    test "returns false when the user isn't a member of the publication" do
      user = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        role: :owner
      )

      refute Publications.member?(publication, user)
    end
  end

  describe "insert_publication/1" do
    test "inserts a publication when the attributes are valid" do
      %User{id: owner_id} = Factory.insert(:user)

      attrs =
        @valid_attrs
        |> Map.put(:owner_id, owner_id)

      assert {:ok, %{publication: %Publication{id: publication_id}}} =
               Publications.insert_publication(attrs)

      assert %Publication{id: ^publication_id} = Publications.get_publication(publication_id)
    end

    test "doesn't insert a publication when the attributes are invalid" do
      owner = Factory.insert(:user)

      invalid_attrs =
        @valid_attrs
        |> Map.put(:name, "Bad_name!?")
        |> Map.put(:owner_id, owner.id)

      assert {:error, _, _, _} = Publications.insert_publication(invalid_attrs)
    end

    test "inserts the tags if they don't exist already" do
      %User{id: owner_id} = Factory.insert(:user)
      tag_titles = ["test", "elixir", "phoenix", "publication", "margaret"]

      # Make sure that the tags didn't exist before.
      Enum.each(tag_titles, fn tag_title ->
        assert is_nil(Tags.get_tag_by_title(tag_title))
      end)

      attrs =
        @valid_attrs
        |> Map.put(:tags, tag_titles)
        |> Map.put(:owner_id, owner_id)

      assert {:ok, _} = Publications.insert_publication(attrs)

      Enum.each(tag_titles, fn tag_title ->
        assert %Tag{title: ^tag_title} = Tags.get_tag_by_title(tag_title)
      end)
    end

    test "inserts the owner publication membership" do
      owner = Factory.insert(:user)

      attrs =
        @valid_attrs
        |> Map.put(:owner_id, owner.id)

      assert {:ok, %{publication: publication}} = Publications.insert_publication(attrs)

      assert Publications.member?(publication, owner)
      assert Publications.owner?(publication, owner)
    end
  end

  describe "update_publication/2" do
    test "updates the publication when the attributes are valid" do
      publication = Factory.insert(:publication, description: "Old description.")
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      attrs = %{description: "New description."}

      assert {:ok, %{publication: %Publication{}}} =
               Publications.update_publication(publication, attrs)

      updated_publication = Publications.get_publication(publication.id)

      assert updated_publication.description === attrs.description
    end

    test "doesn't update the publication when the attributes are invalid" do
      publication = Factory.insert(:publication, name: "test")
      Factory.insert(:publication_membership, publication: publication, role: :owner)

      invalid_attrs = %{name: "__bad_Name_!"}

      assert {:error, _, _, _} = Publications.update_publication(publication, invalid_attrs)
    end

    test "inserts the tags if they don't exist already" do
      publication = Factory.insert(:publication, tags: [])
      Factory.insert(:publication_membership, publication: publication, role: :owner)
      tag_titles = ["test", "elixir", "phoenix", "publication", "margaret"]

      # Make sure that the tags didn't exist before.
      Enum.each(tag_titles, fn tag_title ->
        assert is_nil(Tags.get_tag_by_title(tag_title))
      end)

      attrs = %{tags: tag_titles}

      assert {:ok, %{publication: %Publication{}}} =
               Publications.update_publication(publication, attrs)

      Enum.each(tag_titles, fn tag_title ->
        assert %Tag{title: ^tag_title} = Tags.get_tag_by_title(tag_title)
      end)
    end
  end

  describe "owner/1" do
    test "returns the owner of the publication" do
      owner = Factory.insert(:user)
      publication = Factory.insert(:publication)

      Factory.insert(
        :publication_membership,
        publication: publication,
        member: owner,
        role: :owner
      )

      Factory.insert_list(3, :publication_membership, publication: publication, role: :writer)

      assert Publications.owner(publication).id === owner.id
    end
  end
end
