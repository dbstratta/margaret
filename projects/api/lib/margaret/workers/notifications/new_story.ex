defmodule Margaret.Workers.Notifications.NewStory do
  @moduledoc """
  Worker that enqueues notification insertions for new stories.
  """

  alias Ecto.Multi

  alias Margaret.{Stories, Notifications}
  alias Stories.Story

  def perform(story_id, timestamp) do
    with %Story{published_at: published_at} = story <- Stories.get_story(story_id),
         actual_timestamp = from_naive_to_unix!(published_at),
         # We compare that the time of publication of the story is still
         # the same as the one we enqueued the job with.
         # If it's not, that means that the `published_at` was updated
         # after this job was enqueued. And if so, this job becomes useless.
         true <- actual_timestamp === timestamp,
         notified_users = Stories.notifiable_users_of_new_story(story),
         notification_attrs = %{
           actor_id: story.author_id,
           action: "added",
           story_id: story.id,
           notified_users: notified_users
         },
         {:ok, _} <- Notifications.insert_notification(notification_attrs) do
      {:ok, nil}
    else
      _ -> {:error, nil}
    end
  end

  @doc """
  Puts the notification insertion job in the multi.

  ## Examples

    iex> Ecto.Multi.new() |> enqueue_notification()
    iex> %Ecto.Multi{}

  """
  @spec enqueue_notification(Multi.t()) :: Multi.t()
  def enqueue_notification(multi) do
    Multi.run(multi, :new_story_notification, fn
      %{story: %Story{id: story_id, published_at: published_at}}
      when not is_nil(published_at) ->
        timestamp = from_naive_to_unix!(published_at)

        args = [story_id, timestamp]
        Exq.enqueue_at(Exq, "notifications", timestamp, __MODULE__, args)

      _ ->
        {:error, nil}
    end)
  end

  # Converts a naive datetime to a unix timestamp.
  @spec from_naive_to_unix!(NaiveDateTime.t()) :: integer()
  defp from_naive_to_unix!(%NaiveDateTime{} = naive_datetime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix()
  end
end
