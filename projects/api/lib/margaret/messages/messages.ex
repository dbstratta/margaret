defmodule Margaret.Messages do
  @moduledoc """
  The Messages context.
  """

  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Messages
  }

  alias Messages.Message

  @doc """
  """
  def get_message(id), do: Repo.get(Message, id)

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
    multi
  end
end
