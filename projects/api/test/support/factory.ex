defmodule Margaret.Factory do
  @moduledoc """
  Factory functions to use in tests.
  """

  use ExMachina.Ecto, repo: Margaret.Repo

  alias Margaret.{
    Accounts,
    Stories,
    Comments,
    Publications,
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
  alias Notifications.{Notification, UserNotification}
  alias Stars.Star
  alias Bookmarks.Bookmark
  alias Follows.Follow
  alias Tags.Tag

  def user_factory do
    %User{
      username: sequence(:username, &"user-#{&1}"),
      email: sequence(:email, &"user-#{&1}@margaret.test"),
      bio: "Test user.",
      website: "https://margaret.test"
    }
  end

  def social_login_factory do
    %SocialLogin{
      uid: sequence(:uid, &"uid-#{&1}"),
      provider: "github",
      user: build(:user)
    }
  end

  def story_factory do
    %Story{
      content: %{"blocks" => [%{"text" => "test"}]},
      author: build(:user),
      unique_hash: sequence(:unique_hash, &"unique_hash-#{&1}"),
      audience: :all,
      license: :all_rights_reserved,
      comments: build_list(3, :comment),
      stars: build_list(1, :star),
      views: build_list(3, :story_view),
      tags: build_pair(:tag)
    }
  end

  def story_view_factory do
    %StoryView{
      story: build(:story),
      viewer: build(:user)
    }
  end

  def comment_factory do
    %Comment{
      content: %{"blocks" => [%{"text" => "test"}]},
      author: build(:user),
      stars: build_list(1, :star),
      story: build(:story)
    }
  end

  def publication_factory do
    %Publication{
      name: sequence(:name, &"publication-#{&1}"),
      display_name: sequence(:display_name, &"Publication #{&1}"),
      description: "Test publication.",
      website: "https://margaret.test",
      publication_memberships: [build(:publication_membership, %{role: :owner})],
      followers: build_list(3, :user),
      tags: build_list(1, :tag)
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

  def notification_factory do
    %Notification{
      actor: build(:user),
      action: :followed,
      user: build(:user)
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
      user: build(:user),
      story: build(:story)
    }
  end

  def bookmark_factory do
    %Bookmark{
      user: build(:user),
      story: build(:story)
    }
  end

  def follow_factory do
    %Follow{
      follower: build(:user),
      user: build(:user)
    }
  end

  def tag_factory do
    %Tag{
      title: sequence(:title, &"tag-#{&1}")
    }
  end
end
