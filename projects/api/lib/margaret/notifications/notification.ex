defmodule Margaret.Notifications.Notification do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__
  alias Margaret.{Accounts, Notifications, Stories, Publications, Comments}
  alias Accounts.User
  alias Notifications.UserNotification
  alias Stories.Story
  alias Publications.Publication
  alias Comments.Comment

  @type t :: %Notification{}

  @permitted_attrs [
    :actor_id,
    :action,
    :story_id,
    :comment_id,
    :publication_id,
    :user_id
  ]

  @required_attrs [
    :action
  ]

  defenum NotificationAction, :notification_action, [
    :added,
    :updated,
    :deleted,
    :followed,
    :starred,
    :commented
  ]

  schema "notifications" do
    belongs_to(:actor, User)
    field(:action, NotificationAction)
    many_to_many(:notified_users, User, join_through: UserNotification)

    belongs_to(:story, Story)
    belongs_to(:comment, Comment)
    belongs_to(:publication, Publication)
    belongs_to(:user, User)

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
    |> check_constraint(:action, name: :only_one_not_null_object)
    |> maybe_put_notified_users(attrs)
    |> validate_action()
  end

  # TODO: validate that the action and object combination makes sense.
  defp validate_action(changeset) do
    changeset
  end

  defp maybe_put_notified_users(%Ecto.Changeset{} = changeset, %{notified_users: notified_users}) do
    put_assoc(changeset, :notified_users, notified_users)
  end

  defp maybe_put_notified_users(%Ecto.Changeset{} = changeset, _attrs), do: changeset
end
