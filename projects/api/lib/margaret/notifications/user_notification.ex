defmodule Margaret.Notifications.UserNotification do
  @moduledoc """
  The User Notification schema and changesets.
  """

  use Ecto.Schema
  import Ecto.{Changeset, Query}

  alias __MODULE__

  alias Margaret.{
    Repo,
    Accounts.User,
    Notifications.Notification
  }

  @type t :: %UserNotification{}

  @primary_key false
  schema "user_notifications" do
    belongs_to(:user, User, primary_key: true)

    belongs_to(:notification, Notification, primary_key: true)

    field(:read_at, :naive_datetime)
  end

  @doc """
  Builds a changeset for inserting a user notification.
  """
  def changeset(attrs) do
    permitted_attrs = ~w(
      user_id
      notification_id
      read_at
    )a

    required_attrs = ~w(
      user_id
      notification_id
    )a

    %UserNotification{}
    |> cast(attrs, permitted_attrs)
    |> validate_required(required_attrs)
    |> assoc_constraint(:user)
    |> assoc_constraint(:notification)
  end

  @doc """
  Builds a changeset for updating a user notification.
  """
  def update_changeset(%UserNotification{} = user_notification, attrs) do
    permitted_attrs = ~w(
      read_at
    )a

    user_notification
    |> cast(attrs, permitted_attrs)
  end

  @doc """
  Filters the user notifications by user.
  """
  @spec by_user(Ecto.Query.t(), User.t()) :: Ecto.Query.t()
  def by_user(query \\ UserNotification, %User{id: user_id}),
    do: where(query, [..., un], un.user_id == ^user_id)

  @doc """
  Preloads the user of a user notification.
  """
  @spec preload_user(t) :: t
  def preload_user(%UserNotification{} = user_notification),
    do: Repo.preload(user_notification, :user)

  @doc """
  Preloads the notification of a user notification.
  """
  @spec preload_notification(t) :: t
  def preload_notification(%UserNotification{} = user_notification),
    do: Repo.preload(user_notification, :notification)
end
