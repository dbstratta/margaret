defmodule Margaret.Notifications.Queries do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{Accounts, Notifications}
  alias Accounts.User
  alias Notifications.Notification

  @spec notifications(map()) :: Ecto.Query.t()
  def notifications(args \\ %{}) do
    query = Notification

    query
    |> maybe_filter_by_notified_user(args)
  end

  defp maybe_filter_by_notified_user(query, args) do
    case Map.get(args, :notified_user) do
      %User{id: notified_user_id} ->
        from(
          n in query,
          join: un in assoc(n, :user_notifications),
          where: un.user_id == ^notified_user_id
        )

      nil ->
        query
    end
  end
end
