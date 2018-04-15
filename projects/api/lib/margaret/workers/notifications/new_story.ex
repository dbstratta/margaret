defmodule Margaret.Workers.Notifications.NewStory do
  @moduledoc """
  Worker that enqueues notification insertions for new stories.
  """

  alias Ecto.Multi

  alias Margaret.Stories
  alias Stories.Story

  def perform(story_id, timestamp) do
    # TODO:
    with %Story{published_at: published_at} = story <- Stories.get_story(story_id),
         actual_timestamp = from_naive_to_unix!(published_at),
         true <- actual_timestamp === timestamp,
         _notifiable_users = Stories.get_notifiable_users_of_new_story(story) do
      {:ok, 3}
    else
      _ -> {:error, ""}
    end
  end

  @doc """
  Puts the notification insertion job in the multi.

  ## Examples

    iex> Ecto.Multi.new() |> enqueue_notification(story)
    iex> %Ecto.Multi{}

  """
  @spec enqueue_notification(Multi.t(), Story.t()) :: Multi.t()
  def enqueue_notification(multi, %Story{id: story_id, published_at: time})
      when not is_nil(time) do
    timestamp = from_naive_to_unix!(time)

    args = [story_id, timestamp]

    Multi.run(multi, :notification_jid, fn _ ->
      Exq.enqueue_at(Exq, "notifications", timestamp, __MODULE__, args)
    end)
  end

  defp from_naive_to_unix!(%NaiveDateTime{} = naive_datetime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_unix()
  end
end
