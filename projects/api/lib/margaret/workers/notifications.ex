defmodule Margaret.Workers.Notifications do
  @moduledoc """
  Worker that enqueues notification insertions.
  """

  alias Ecto.Multi

  def perform(attrs) do
    {:ok, _} =
      attrs
      |> Margaret.Helpers.atomify_map(values: [:action])
      |> Margaret.Notifications.insert_notification()
  end

  @doc """
  Puts the notification insertion job in the multi.

  ## Examples

    iex> Ecto.Multi.new() |> enqueue_notification_insertion(attrs)
    iex> %Ecto.Multi{}

  """
  def enqueue_notification_insertion(multi, attrs) do
    Multi.run(multi, :notification_jid, fn _ ->
      Exq.enqueue(Exq, "notifications", __MODULE__, [attrs])
    end)
  end
end
