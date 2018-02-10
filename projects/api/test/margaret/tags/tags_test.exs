defmodule Margaret.TagsTest do
  use Margaret.DataCase

  @valid_attrs %{
    title: "test_tag"
  }

  describe "changeset/1" do
    test "with valid attributes" do
      %Changeset{valid?: valid_changeset?} = Tag.changeset(@valid_attrs)

      assert valid_changeset?
    end

    test "with invalid username" do
      attrs = %{@valid_attrs | title: 2}

      %Changeset{valid?: valid_changeset?} = Tag.changeset(attrs)

      refute valid_changeset?
    end

    test "with missing attributes" do
      attrs = %{}

      %Changeset{valid?: valid_changeset?} = Tag.changeset(attrs)

      refute valid_changeset?
    end
  end

  describe "insert_tag/1" do
    test "with valid data inserts a tag" do
      assert {:ok, %Tag{} = tag} = Tags.insert_tag(@valid_attrs)

      assert tag.title === @valid_attrs.title
    end

    test "with invalid data fails" do
      invalid_attrs = %{@valid_attrs | title: 2}
      assert {:error, _} = Tags.insert_tag(invalid_attrs)
    end

    test "with duplicated title fails" do
      assert {:ok, _} = Tags.insert_tag(@valid_attrs)
      assert {:error, _} = Tags.insert_tag(@valid_attrs)
    end
  end

  describe "get_tag/1" do
    test "with valid id returns the tag" do
      %Tag{id: tag_id} = Factory.insert(:tag)

      assert %Tag{id: ^tag_id} = Tags.get_tag(tag_id)
    end

    test "with invalid id returns nil" do
      tag_id = System.unique_integer([:positive])

      assert is_nil(Tags.get_tag(tag_id))
    end
  end

  describe "get_tag!/1" do
    test "with valid id returns the tag" do
      %Tag{id: tag_id} = Factory.insert(:tag)

      assert %Tag{id: ^tag_id} = Tags.get_tag!(tag_id)
    end

    test "with invalid id raises Ecto.NoResultsError" do
      tag_id = System.unique_integer([:positive])

      assert_raise Ecto.NoResultsError, fn ->
        Tags.get_tag!(tag_id)
      end
    end
  end

  describe "get_tag_by_title/1" do
    test "with valid title returns the tag" do
      %Tag{title: title} = Factory.insert(:tag)

      assert %Tag{title: ^title} = Tags.get_tag_by_title(title)
    end

    test "with invalid title returns nil" do
      title = "tag#{System.unique_integer([:positive])}"

      assert is_nil(Tags.get_tag_by_title(title))
    end
  end

  describe "insert_and_get_all_tags/1" do
    test "with valid tag title list" do
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
