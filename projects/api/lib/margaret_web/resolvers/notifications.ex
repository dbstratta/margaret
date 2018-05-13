defmodule MargaretWeb.Resolvers.Notifications do
  @moduledoc """
  The Notification GraphQL resolvers.
  """

  import Margaret.Helpers, only: [ok: 1]
  alias MargaretWeb.Helpers
  alias Margaret.Notifications

  @doc """
  """
  def resolve_object(notification, _, _) do
    notification
    |> Notifications.object()
    |> ok()
  end

  @doc """
  """
  def resolve_actor(notification, _, _) do
    notification
    |> Notifications.actor()
    |> ok()
  end

  @doc """
  """
  def resolve_read_at(notification, _args, %{context: %{viewer: viewer}}) do
    [user_id: viewer.id, notification_id: notification.id]
    |> Notifications.get_user_notification()
    |> Map.fetch!(:read_at)
    |> ok()
  end

  def resolve_read_notification(_, _) do
    Helpers.GraphQLErrors.not_implemented()
  end
end
