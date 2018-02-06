defmodule Margaret.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{Repo, Notifications, Accounts, Stories}
  alias Notifications.{Notification, UserNotification}
  alias Accounts.User
  alias Stories.Story

  @type notification_object :: any

  @doc """

  """
  @spec get_notification(String.t() | non_neg_integer) :: Notification.t() | nil
  def get_notification(id), do: Repo.get(Notification, id)

  @doc """
  Gets the actor of a notification.
  """
  @spec get_actor(Notification.t()) :: User.t() | nil
  def get_actor(%Notification{} = notification) do
    notification
    |> Notification.preload_actor()
    |> Map.get(:actor)
  end

  @doc """
  Gets the object of a notification.
  TODO: Implement this.
  """
  @spec get_object(Notification.t()) :: notification_object
  def get_object(%Notification{}), do: nil

  @doc """
  Returns a user notification.
  """
  def get_user_notification(clauses) when length(clauses) == 2,
    do: Repo.get_by(UserNotification, clauses)

  @doc """
  Inserts a notification.
  """
  def insert_notification(attrs) do
    Multi.new()
    |> notify_users(attrs)
    |> insert_notification(attrs)
    |> Repo.transaction()
  end

  defp notify_users(multi, %{story_id: story_id, action: :starred}) do
    notified_users_fn = fn _ ->
      query =
        from(
          u in User,
          join: s in assoc(u, :stories),
          where: s.id == ^story_id
        )

      case Repo.one(query) do
        %User{} = user -> {:ok, [user]}
        nil -> {:error, nil}
      end
    end

    do_notify_users(multi, notified_users_fn)
  end

  defp notify_users(multi, %{comment_id: comment_id, action: :starred}) do
    notified_users_fn = fn _ ->
      query =
        from(
          u in User,
          join: c in assoc(u, :comments),
          where: c.id == ^comment_id
        )

      case Repo.one(query) do
        %User{} = user -> {:ok, [user]}
        nil -> {:error, nil}
      end
    end

    do_notify_users(multi, notified_users_fn)
  end

  defp notify_users(multi, %{user_id: user_id, action: :followed}) do
    notified_users_fn = fn _ ->
      case Accounts.get_user(user_id) do
        %User{} = user -> {:ok, [user]}
        nil -> {:error, nil}
      end
    end

    do_notify_users(multi, notified_users_fn)
  end

  defp notify_users(multi, %{actor_id: author_id, story_id: story_id, action: :added}) do
    notification_object_fn = fn _ ->
      case Stories.get_story(story_id) do
        %Story{} = story -> {:ok, story}
        nil -> {:error, nil}
      end
    end

    notified_users_fn = fn %{notification_object: %Story{publication_id: publication_id}} ->
      query =
        from(
          u in User,
          join: f in assoc(u, :followers),
          where: f.user_id == ^author_id
        )

      query =
        if not is_nil(publication_id) do
          or_where(query, [user, follow], follow.publication == ^publication_id)
        else
          query
        end

      users = Repo.all(query)

      {:ok, users}
    end

    # Get the story inside the transaction before notifying users.
    multi
    |> Multi.run(:notification_object, notification_object_fn)
    |> do_notify_users(notified_users_fn)
  end

  defp do_notify_users(multi, cb), do: Multi.run(multi, :notified_users, cb)

  defp insert_notification(multi, attrs) do
    insert_notification_fn = fn %{notified_users: notified_users} ->
      attrs
      |> Map.put(:notified_users, notified_users)
      |> Notification.changeset()
      |> Repo.insert()
    end

    Multi.run(multi, :notification, insert_notification_fn)
  end

  @doc """
  Gets the notificatino count of a user.
  """
  @spec get_notification_count(User.t()) :: non_neg_integer
  def get_notification_count(%User{id: user_id}) do
    query =
      from(
        n in Notification,
        join: un in UserNotification,
        on: un.notification_id == n.id,
        where: un.user_id == ^user_id,
        select: count(n.id)
      )

    Repo.one!(query)
  end
end
