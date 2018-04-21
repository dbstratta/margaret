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

      iex> actor(%Notification{})
      %User{}

      iex> actor(%Notification{})
      nil

  """
  @spec actor(Notification.t()) :: User.t() | nil
  def actor(%Notification{} = notification) do
    notification
    |> Notification.preload_actor()
    |> Map.get(:actor)
  end

  @doc """
  Gets the object of a notification.

  ## Examples

      iex> object(%Notification{})
      %Story{}

      iex> object(%Notification{})
      %Publication{}

  """
  @spec object(Notification.t()) :: notification_object
  def object(%Notification{story_id: story_id} = notification) when not is_nil(story_id) do
    notification
    |> Notification.preload_story()
    |> Map.get(:story)
  end

  def object(%Notification{comment_id: comment_id} = notification)
      when not is_nil(comment_id) do
    notification
    |> Notification.preload_comment()
    |> Map.get(:comment)
  end

  def object(%Notification{publication_id: publication_id} = notification)
      when not is_nil(publication_id) do
    notification
    |> Notification.preload_publication()
    |> Map.get(:publication)
  end

  def object(%Notification{user_id: user_id} = notification) when not is_nil(user_id) do
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
    |> insert_notification(attrs)
    |> Repo.transaction()
  end

  @spec insert_notification(Multi.t(), map()) :: Multi.t()
  defp insert_notification(multi, attrs) do
    notification_changeset = Notification.changeset(attrs)

    Multi.insert(multi, :notification, notification_changeset)
  end

  @doc """
  Marks as read a user notification

  ## Examples

      iex> read(%UserNotification{})
      {:ok, %UserNotification{}}

  """
  @spec read(UserNotification.t()) :: {:ok, UserNotification.t()} | {:error, Ecto.Changeset.t()}
  def read(%UserNotification{} = user_notification) do
    update_user_notification(user_notification, %{read_at: NaiveDateTime.utc_now()})
  end

  defp update_user_notification(%UserNotification{} = user_notification, attrs) do
    user_notification
    |> UserNotification.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Gets the notificatino count of a user.
  """
  @spec notification_count(User.t()) :: non_neg_integer
  def notification_count(%User{} = user) do
    query =
      Notification
      |> join(:inner, [n], un in assoc(n, :user_notifications))
      |> UserNotification.by_user(user)

    Repo.count(query)
  end
end
