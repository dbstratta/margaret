defmodule Margaret.Factory do
  @moduledoc """
  Factory functions to use in tests.

  ## Examples

      iex> Factory.insert(:user)
      %User{}

  """

  use ExMachina.Ecto, repo: Margaret.Repo

  alias Margaret.{
    Accounts,
    Stories,
    Comments,
    Publications,
    Collections,
    Notifications,
    Stars,
    Bookmarks,
    Follows,
    Tags
  }

  alias Accounts.{User, SocialLogin}
  alias Stories.{Story, StoryView}
  alias Comments.Comment
  alias Publications.{Publication, PublicationInvitation, PublicationMembership}
  alias Collections.{Collection, CollectionStory}
  alias Notifications.{Notification, UserNotification}
  alias Stars.Star
  alias Bookmarks.Bookmark
  alias Follows.Follow
  alias Tags.Tag

  def notification_settings_factory do
    %Accounts.Settings.Notifications{}
  end

  def user_settings_factory do
    %Accounts.Settings{
      notifications: params_for(:notification_settings)
    }
  end

  @spec user_factory :: User.t()
  def user_factory do
    %User{
      username: sequence(:username, &"user#{&1}"),
      email: sequence(:email, &"user#{&1}@margaret.test"),
      settings: build(:user_settings)
    }
  end

  @spec social_login_factory :: SocialLogin.t()
  def social_login_factory do
    %SocialLogin{
      uid: sequence(:uid, &"uid#{&1}"),
      provider: "github",
      user: build(:user)
    }
  end

  @spec story_factory :: Story.t()
  def story_factory do
    %Story{
      content: %{"blocks" => [%{"text" => "test"}]},
      author: build(:user),
      unique_hash: sequence(:unique_hash, &"abc#{&1}"),
      audience: :all,
      license: :all_rights_reserved
    }
  end

  @spec story_view_factory :: StoryView.t()
  def story_view_factory do
    %StoryView{
      story: build(:story)
    }
  end

  @spec comment_factory :: Comment.t()
  def comment_factory do
    %Comment{
      content: %{"blocks" => [%{"text" => "test"}]},
      author: build(:user),
      story: build(:story)
    }
  end

  @spec publication_factory :: Publication.t()
  def publication_factory do
    %Publication{
      name: sequence(:name, &"publication-#{&1}"),
      display_name: sequence(:display_name, &"Publication #{&1}"),
      description: "Test publication.",
      website: "https://example.com"
    }
  end

  def publication_invitation_factory do
    %PublicationInvitation{
      invitee: build(:user),
      inviter: build(:user),
      publication: build(:publication),
      role: :writer,
      status: :pending
    }
  end

  def publication_membership_factory do
    %PublicationMembership{
      role: :writer,
      member: build(:user),
      publication: build(:publication)
    }
  end

  def collection_factory do
    %Collection{
      title: sequence(:title, &"Collection #{&1}"),
      subtitle: "Collection subtitle",
      slug: sequence(:slug, &"collection-slug-#{&1}"),
      author: build(:user)
    }
  end

  def collection_story_factory do
    %CollectionStory{
      collection: build(:collection),
      story: build(:story),
      part: 1
    }
  end

  def notification_factory do
    %Notification{
      actor: build(:user),
      action: :followed
    }
  end

  def user_notification_factory do
    %UserNotification{
      user: build(:user),
      notification: build(:notification)
    }
  end

  def star_factory do
    %Star{
      user: build(:user)
    }
  end

  def bookmark_factory do
    %Bookmark{
      user: build(:user)
    }
  end

  def follow_factory do
    %Follow{
      follower: build(:user)
    }
  end

  def tag_factory do
    %Tag{
      title: sequence(:title, &"tag-#{&1}")
    }
  end
end
