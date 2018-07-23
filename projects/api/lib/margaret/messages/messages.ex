defmodule Margaret.Messages do
  @moduledoc """
  The Messages context.
  """

  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Notifications,
    Messages
  }

  alias Messages.Message

  @doc """
  """
  def get_message(id) do
    Repo.get(Message, id)
  end

  def recipient(%Message{} = message) do
    message
    |> Message.preload_recipient()
    |> Map.fetch!(:recipient)
  end

  @doc """
  """
  def insert_message(attrs) do
    Multi.new()
    |> insert_message(attrs)
    |> notify_recipient(attrs)
    |> Repo.transaction()
  end

  defp insert_message(multi, attrs) do
    changeset = Message.changeset(attrs)
    Multi.insert(multi, :message, changeset)
  end

  defp notify_recipient(multi, _attrs) do
    insert_notification_fn = fn %{message: message} ->
      recipient = Messages.recipient(message)

      notification_attrs = %{
        actor_id: message.sender_id,
        action: "added",
        message_id: message.id,
        notified_users: [recipient]
      }

      Notifications.insert_notification(notification_attrs)
    end

    Multi.run(multi, :notify_recipient, insert_notification_fn)
  end
end
