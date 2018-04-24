defmodule Margaret.TagTest do
  use Margaret.DataCase

  @valid_attrs %{
    title: "test_tag"
  }

  describe "changeset/1" do
    test "is valid when the attributes are valid" do
      %Changeset{valid?: valid_changeset?} = Tag.changeset(@valid_attrs)

      assert valid_changeset?
    end

    test "is invalid when the title is invalid" do
      attrs = %{@valid_attrs | title: 2}

      %Changeset{valid?: valid_changeset?} = Tag.changeset(attrs)

      refute valid_changeset?
    end

    test "is invalid when required attributes are missing" do
      attrs = %{}

      %Changeset{valid?: valid_changeset?} = Tag.changeset(attrs)

      refute valid_changeset?
    end
  end

  describe "by_titles/2" do
    test "matches only the specified tags by their titles" do
      titles = ["elixir", "test"]

      Enum.each(titles, fn title ->
        Factory.insert(:tag, title: title)
      end)

      query = Tag.by_titles(titles)
      tags = Repo.all(query)

      assert length(tags) == length(titles)

      Enum.each(tags, fn tag ->
        assert tag.title in titles
      end)
    end
  end

  test "implemets String.Chars protocol" do
    tag = Factory.insert(:tag)

    assert is_binary(to_string(tag))
  end
end
