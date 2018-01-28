defmodule MargaretWeb.Resolvers.Notifications do
  @moduledoc """
  The Notification GraphQL resolvers.
  """

  alias MargaretWeb.Helpers

  alias Margaret.{Repo, Notifications}
  alias Notifications.{Notification, UserNotification}

  @doc """
  """
  def resolve_object(%Notification{} = notification, _, _) do
    key =
      cond do
        not is_nil(notification.story_id) -> :story
        not is_nil(notification.user_id) -> :user
        not is_nil(notification.publication_id) -> :publication
      end

    object =
      notification
      |> Repo.preload(key)
      |> Map.get(key)

    {:ok, object}
  end

  @doc """
  """
  def resolve_actor(%Notification{} = notification, _, _) do
    actor =
      notification
      |> Repo.preload(:actor)
      |> Map.get(:actor)

    {:ok, actor}
  end

  @doc """
  """
  def resolve_read_at(%Notification{id: notification_id}, _, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    %UserNotification{read_at: read_at} =
      Notifications.get_user_notification(%{user_id: viewer_id, notification_id: notification_id})

    {:ok, read_at}
  end

  def resolve_read_notification(_, _) do
    Helpers.GraphQLErrors.not_implemented()
  end
end
