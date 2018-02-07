defmodule MargaretWeb.Resolvers.Notifications do
  @moduledoc """
  The Notification GraphQL resolvers.
  """

  alias MargaretWeb.Helpers

  alias Margaret.Notifications
  alias Notifications.{Notification, UserNotification}

  @doc """
  """
  def resolve_object(notification, _, _) do
    object = Notifications.get_object(notification)

    {:ok, object}
  end

  @doc """
  """
  def resolve_actor(notification, _, _) do
    actor = Notifications.get_actor(notification)

    {:ok, actor}
  end

  @doc """
  """
  def resolve_read_at(%Notification{id: notification_id}, _, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    %UserNotification{read_at: read_at} =
      Notifications.get_user_notification(user_id: viewer_id, notification_id: notification_id)

    {:ok, read_at}
  end

  def resolve_read_notification(_, _) do
    Helpers.GraphQLErrors.not_implemented()
  end
end
