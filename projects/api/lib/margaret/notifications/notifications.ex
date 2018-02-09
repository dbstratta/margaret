defmodule Margaret.Notifications do
  @moduledoc """
  The Notifications context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Notifications,
    Accounts,
    Stories
  }

  alias Notifications.{Notification, UserNotification}
  alias Accounts.User
  alias Stories.Story

  @type notification_object :: Story.t() | Comment.t() | Publication.t() | User.t()

  @doc """
  Gets a notification.

  ## Examples

      iex> get_notification(123)
      %Notification{}

      iex> get_notification(456)
      nil

  """
  @spec get_notification(String.t() | non_neg_integer) :: Notification.t() | nil
  def get_notification(id), do: Repo.get(Notification, id)

  @doc """
  Gets the actor of a notification.

  ## Examples

      iex> get_actor(%Notification{})
      %User{}

      iex> get_actor(%Notification{})
      nil

  """
  @spec get_actor(Notification.t()) :: User.t() | nil
  def get_actor(%Notification{} = notification) do
    notification
    |> Notification.preload_actor()
    |> Map.get(:actor)
  end

  @doc """
  Gets the object of a notification.

  ## Examples

      iex> get_object(%Notification{})
      %Story{}

      iex> get_object(%Notification{})
      %Publication{}

  """
  @spec get_object(Notification.t()) :: notification_object
  def get_object(%Notification{story_id: story_id} = notification) when not is_nil(story_id) do
    notification
    |> Notification.preload_story()
    |> Map.get(:story)
  end

  def get_object(%Notification{comment_id: comment_id} = notification)
      when not is_nil(comment_id) do
    notification
    |> Notification.preload_comment()
    |> Map.get(:comment)
  end

  def get_object(%Notification{publication_id: publication_id} = notification)
      when not is_nil(publication_id) do
    notification
    |> Notification.preload_publication()
    |> Map.get(:publication)
  end

  def get_object(%Notification{user_id: user_id} = notification) when not is_nil(user_id) do
    notification
    |> Notification.preload_user()
    |> Map.get(:user)
  end

  @doc """
  Returns a user notification.

  ## Examples

      iex> get_user_notification([user_id: 123, notification_id: 123])
      %UserNotification{}

      iex> get_user_notification([user_id: 123, notification_id: 456])
      nil

  """
  @spec get_user_notification(Keyword.t()) :: UserNotification.t()
  def get_user_notification(clauses) when length(clauses) == 2,
    do: Repo.get_by(UserNotification, clauses)

  @doc """
  Inserts a notification.
  """
  @spec insert_notification(any) :: {:ok, any} | {:error, any, any, any}
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
  def get_notification_count(%User{} = user) do
    query =
      Notification
      |> join(:inner, [n], un in assoc(n, :user_notifications))
      |> UserNotification.by_user(user)

    Repo.aggregate(query, :count, :id)
  end
end
