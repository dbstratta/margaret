defmodule Margaret.PublicationsTest do
  use Margaret.DataCase

  @valid_attrs %{}

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
      publication = Factory.insert(:publication)
      Factory.insert(:publication_membership, publication: publication, role: :owner)
    end
  end
end
