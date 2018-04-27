import Ecto
import Ecto.{Changeset, Query}
alias Ecto.Changeset

alias Margaret.{
  Repo,
  Accounts,
  Stories,
  Comments,
  Publications,
  Collections,
  Follows,
  Stars,
  Bookmarks,
  Tags,
  Notifications,
  Factory
}

alias Accounts.{User, SocialLogin}
alias Stories.{Story, StoryView}
alias Comments.Comment
alias Publications.{Publication, PublicationInvitation, PublicationMembership}
alias Collections.{Collection, CollectionStory}
alias Follows.Follow
alias Stars.Star
alias Bookmarks.Bookmark
alias Tags.Tag
alias Notifications.{Notification, UserNotification}
