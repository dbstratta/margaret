defmodule Margaret.Notifications.Notification do
  @moduledoc """
  The Notification schema and changesets.
  """

  use Ecto.Schema
  import Ecto.Changeset
  import EctoEnum, only: [defenum: 3]

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Notifications.UserNotification,
    Stories.Story,
    Publications.Publication,
    Comments.Comment
  }

  @type t :: %Notification{}

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

    # Notification objects.
    belongs_to(:story, Story)
    belongs_to(:comment, Comment)
    belongs_to(:publication, Publication)
    belongs_to(:user, User)

    timestamps()
  end

  @doc """
  Builds a changeset for inserting a notification.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      actor_id
      action
      story_id
      comment_id
      publication_id
      user_id
    )a

    required_attrs = ~w(
      action
    )a

    %Notification{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:actor)
    |> assoc_constraint(:story)
    |> assoc_constraint(:comment)
    |> assoc_constraint(:publication)
    |> assoc_constraint(:user)
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

  @doc """
  Preloads the actor of a notification.
  """
  @spec preload_actor(t) :: t
  def preload_actor(%Notification{} = notification), do: Repo.preload(notification, :actor)
end
