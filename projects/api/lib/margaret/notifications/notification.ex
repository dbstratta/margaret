defmodule Margaret.Notifications.Notification do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__
  alias Margaret.{Accounts, Notifications, Stories, Publications, Comments, Stars}
  alias Accounts.{User, Follow}
  alias Notifications.UserNotification
  alias Stories.Story
  alias Publications.Publication
  alias Comments.Comment
  alias Stars.Star

  @type t :: %Notification{}

  @permitted_attrs [
    :actor_id,
    :action,
    :users,
    :story,
    :comment,
    :publication,
    :user,
    :follow,
    :star
  ]

  @required_attrs [
    :action
  ]

  defenum NotificationAction, :notification_action, [:added, :updated, :deleted]

  schema "notifications" do
    belongs_to(:actor, User)
    field(:action, NotificationAction)
    has_many(:users, UserNotification)

    belongs_to(:story, Story)
    belongs_to(:comment, Comment)
    belongs_to(:publication, Publication)
    belongs_to(:user, User)
    belongs_to(:follow, Follow)
    belongs_to(:star, Star)

    timestamps()
  end

  @doc false
  def changeset(attrs) do
    %Notification{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:actor_id)
    |> foreign_key_constraint(:story_id)
    |> foreign_key_constraint(:comment_id)
    |> foreign_key_constraint(:publication_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:follow_id)
    |> foreign_key_constraint(:star_id)
    |> validate_action()
  end

  defp validate_action(changeset) do
    changeset
  end
end
