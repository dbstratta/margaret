defmodule Margaret.Factory do
  @moduledoc """
  Factory functions to build and insert structs.

  TODO: In the future, it would be pretty nice to
  insert changesets instead of structs directly.
  """

  alias Margaret.{Repo, Accounts, Stories, Comments, Publications, Stars, Bookmarks, Tags}
  alias Accounts.{User, SocialLogin, Follow}
  alias Stories.Story
  alias Comments.Comment
  alias Publications.{Publication, PublicationInvitation, PublicationMembership}
  alias Stars.Star
  alias Bookmarks.Bookmark
  alias Tags.Tag

  @names [
    :user,
    :social_login,
    :follow,
    :story,
    :comment,
    :publication,
    :publication_invitation,
    :publication_membership,
    :star,
    :bookmark,
    :tag
  ]

  @content %{"blocks" => [%{"text" => "Title"}]}

  # Generates the `build_*` functions.
  Enum.each(@names, fn name ->
    def unquote(:"build_#{name}")(fields \\ []) do
      build(unquote(name), fields)
    end
  end)

  # Generates the `insert_*!` functions.
  Enum.each(@names, fn name ->
    def unquote(:"insert_#{name}!")(fields \\ []) do
      Repo.insert!(build(unquote(name), fields))
    end
  end)

  # Factories

  @doc """
  Builds a struct for the given entity.

  ## Examples

    iex> build(:user)
    %User{}

  """
  @spec build(atom) :: any
  def build(:user) do
    %User{
      username: "user#{System.unique_integer()}",
      email: "user#{System.unique_integer()}@example.com"
    }
  end

  def build(:social_login) do
    %SocialLogin{
      uid: "uid_#{System.unique_integer()}",
      provider: "github"
    }
  end

  def build(:follow) do
    %Follow{}
  end

  def build(:story) do
    %Story{
      content: @content,
      audience: :all,
      license: :all_rights_reserved
    }
  end

  def build(:comment) do
    %Comment{
      content: @content
    }
  end

  def build(:publication) do
    %Publication{
      display_name: "Publication #{System.unique_integer()}",
      name: "publication#{System.unique_integer()}"
    }
  end

  def build(:publication_invitation) do
    %PublicationInvitation{}
  end

  def build(:publication_membership) do
    %PublicationMembership{
      role: :writer
    }
  end

  def build(:star) do
    %Star{}
  end

  def build(:bookmark) do
    %Bookmark{}
  end

  def build(:tag) do
    %Tag{
      title: "tag"
    }
  end

  def build(name, fields \\ []) do
    name
    |> build()
    |> struct(fields)
  end
end
