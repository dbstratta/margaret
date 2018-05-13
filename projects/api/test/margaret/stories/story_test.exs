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
end
