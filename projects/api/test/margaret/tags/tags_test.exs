defmodule Margaret.TagsTest do
  use Margaret.DataCase

  @valid_attrs %{
    title: ExMachina.sequence(:title, &"tag-#{&1}")
  }

  describe "get_tag/1" do
    test "returns the tag when the id is valid" do
      %Tag{id: tag_id} = Factory.insert(:tag)

      assert %Tag{id: ^tag_id} = Tags.get_tag(tag_id)
    end

    test "returns nil when the id is invalid" do
      tag_id = System.unique_integer([:positive])

      assert is_nil(Tags.get_tag(tag_id))
    end
  end

  describe "get_tag!/1" do
    test "returns the tag when there is a tag with that id" do
      %Tag{id: tag_id} = Factory.insert(:tag)

      assert %Tag{id: ^tag_id} = Tags.get_tag!(tag_id)
    end

    test "raises when there is not a tag with that id" do
      tag_id = 1

      assert_raise Ecto.NoResultsError, fn ->
        Tags.get_tag!(tag_id)
      end
    end
  end

  describe "get_tag_by_title/1" do
    test "returns the tag when there is a tag with that title" do
      %Tag{title: title} = Factory.insert(:tag)

      assert %Tag{title: ^title} = Tags.get_tag_by_title(title)
    end

    test "returns nil when there ins't a tag with that title" do
      title = ExMachina.sequence(:title, &"tag-#{&1}")

      assert is_nil(Tags.get_tag_by_title(title))
    end
  end

  describe "insert_tag/1" do
    test "inserts a tag when attributes are valid" do
      assert {:ok, %Tag{title: title}} = Tags.insert_tag(@valid_attrs)

      assert title === @valid_attrs.title
    end

    test "doesn't insert a tag when the title is invalid" do
      invalid_attrs = %{@valid_attrs | title: 2}

      assert {:error, _} = Tags.insert_tag(invalid_attrs)
    end

    test "doesn't insert a tag when there is already a tag with the same title" do
      attrs = %{@valid_attrs | title: "title"}

      assert {:ok, _} = Tags.insert_tag(attrs)
      assert {:error, _} = Tags.insert_tag(attrs)
    end
  end

  describe "insert_and_get_all_tags/1" do
    test "inserts and returns all tags" do
      tag_titles = ["tag", "test", "elixir"]

      Enum.each(tag_titles, fn title ->
        assert is_nil(Tags.get_tag_by_title(title))
      end)

      tags = Tags.insert_and_get_all_tags(tag_titles)

      assert length(tag_titles) == length(tags)

      Enum.each(tags, fn tag ->
        assert tag.title in tag_titles
      end)

      Enum.each(tag_titles, fn title ->
        assert %Tag{title: ^title} = Tags.get_tag_by_title(title)
      end)
    end
  end
end
