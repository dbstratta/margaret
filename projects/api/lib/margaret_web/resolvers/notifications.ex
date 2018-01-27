defmodule MargaretWeb.Resolvers.Notifications do
  @moduledoc """
  The Notification GraphQL resolvers.
  """

  alias MargaretWeb.Helpers

  alias Margaret.{Repo, Notifications}
  alias Notifications.{Notification, UserNotification}

  def resolve_object(%Notification{story_id: story_id} = notification, _, _)
      when not is_nil(story_id) do
    story =
      notification
      |> Repo.preload(:story)
      |> Map.get(:story)

    {:ok, story}
  end

  def resolve_object(%Notification{user_id: user_id} = notification, _, _)
      when not is_nil(user_id) do
    user =
      notification
      |> Repo.preload(:user)
      |> Map.get(:user)

    {:ok, user}
  end

  def resolve_actor(%Notification{} = notification, _, _) do
    actor =
      notification
      |> Repo.preload(:actor)
      |> Map.get(:actor)

    {:ok, actor}
  end

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
