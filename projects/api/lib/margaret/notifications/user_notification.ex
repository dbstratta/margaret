defmodule Margaret.Notifications.UserNotification do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Margaret.{Accounts, Notifications}
  alias Accounts.User
  alias Notifications.Notification

  @type t :: %UserNotification{}

  @permitted_attrs [
    "user_id",
    "notification_id",
    "read_at"
  ]

  @required_attrs [
    "user_id",
    "notification_id"
  ]

  @update_permitted_attrs [
    "read_at"
  ]

  schema "user_notifications" do
    belongs_to(:user, User)
    belongs_to(:notification, Notification)
    field(:read_at, :naive_datetime)
  end

  @doc false
  def changeset(attrs) do
    %UserNotification{}
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:notification_id)
  end

  @doc false
  def update_changeset(%UserNotification{} = user_notification, attrs) do
    user_notification
    |> cast(attrs, @update_permitted_attrs)
  end
end
