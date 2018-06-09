defmodule Margaret.Workers.Notifications.NewStory do
  @moduledoc """
  Worker that enqueues notification insertions for new stories.
  """

  alias Ecto.Multi

  alias Margaret.{Stories, Notifications}
  alias Stories.Story

  def perform(story_id, timestamp) do
    with %Story{} = story <- Stories.get_story(story_id),
         true <- published_at_matches?(story, timestamp),
         notified_users = Stories.Notifications.notifiable_users_of_new_story(story) do
      insert_notification(story, notified_users)
    else
      _ -> {:error, nil}
    end
  end

  defp published_at_matches?(story, timestamp) do
    story.published_at
    |> from_naive_to_unix!()
    |> Kernel.===(timestamp)
  end

  defp insert_notification(story, notified_users) do
    attrs = %{
      actor_id: story.author_id,
      action: "added",
      story_id: story.id,
      notified_users: notified_users
    }

    Notifications.insert_notification(attrs)
  end

  @doc """
  Puts the notification insertion job in the multi.

  ## Examples

    iex> Ecto.Multi.new() |> enqueue_notification()
    iex> %Ecto.Multi{}

  """
  @spec enqueue_notification(Multi.t()) :: Multi.t()
  def enqueue_notification(multi, opts \\ []) do
    story_field = get_story_field_from_opts(opts)

    enqueue_notification_fn = fn changes ->
      story = Map.fetch!(changes, story_field)
      timestamp = from_naive_to_unix!(story.published_at)

      args = [story.id, timestamp]
      Exq.enqueue_at(Exq, "notifications", timestamp, __MODULE__, args)
    end

    Multi.run(multi, :new_story_notification, enqueue_notification_fn)
  end

  defp get_story_field_from_opts(opts), do: Keyword.get(opts, :story_field, :story)

  @spec from_naive_to_unix!(NaiveDateTime.t()) :: integer()
  defp from_naive_to_unix!(%NaiveDateTime{} = naive_datetime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix()
  end
end
