# defmodule Margaret.Factory.Injector do
#   defmacro inject_factories(names) do
#     Enum.map(names, fn name ->
#       quote do
#         def unquote(:"build_#{name}")(fields \\ []) do
#           unquote do
#             build(name, fields)
#           end
#         end
#       end
#     end)
#   end

#   defmacro __before_compile__(_env) do
#     inject_factories [
#     ]
#   end
# end

defmodule Margaret.Factory do
  alias Margaret.{Accounts, Stories, Comments, Publications, Stars, Bookmarks, Tags}
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
    :tag,
  ]

  @content %{"blocks" => [%{"text" => "Title"}]}

  Enum.each @names, fn name ->
    def unquote(:"build_#{name}")(fields \\ []) do
      build(unquote(name), fields)
    end
  end

  # Factories

  @spec build(atom) :: any
  def build(:user) do
    %User{
      username: "user#{System.unique_integer()}",
      email: "user#{System.unique_integer()}@example.com",
    }
  end

  def build(:social_login) do
    %SocialLogin{
      uid: "uid_#{System.unique_integer()}",
      provider: :github,
    }
  end

  def build(:follow) do
    %Follow{}
  end

  def build(:story) do
    %Story{
      content: @content,
      audience: :all,
      license: :all_rights_reserved,
    }
  end

  def build(:comment) do
    %Comment{
      content: @content,
    }
  end

  def build(:publication) do
    %Publication{
      display_name: "Publication",
    }
  end

  def build(:publication_invitation) do
    %PublicationInvitation{}
  end

  def build(:publication_membership) do
    %PublicationMembership{
      role: :writer,
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