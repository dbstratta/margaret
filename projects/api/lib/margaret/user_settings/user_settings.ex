defmodule Margaret.UserSettings do
  @moduledoc """
  The User Settings context.
  """

  alias Margaret.{
    Accounts
  }

  alias Accounts.User

  @doc """
  Returns `true` if the user has enabled notifications for
  when one of their stories is starred.

  ## Examples

      iex> starred_story_notifications_enabled(%User{})
      true

  """
  @spec starred_story_notifications_enabled?(User.t()) :: boolean()
  def starred_story_notifications_enabled?(%User{settings: settings}) do
    settings.notifications.starred_story
  end

  @doc """
  Ecto query helper to filter user settings that have enabled
  notifications for new stories.

  ## Examples

      iex> from u in User, where: new_story_notifications_enabled(u.settings)
      #Ecto.Query<...>

  """
  @spec new_story_notifications_enabled(any()) :: Macro.t()
  defmacro new_story_notifications_enabled(settings) do
    quote do
      fragment("(?->'notifications'->>'new_stories')::boolean = true", unquote(settings))
    end
  end

  @doc """
  Ecto query helper to filter user settings that have enabled
  notifications for new followers.

  ## Examples

      iex> from u in User, where: new_story_notifications_enabled(u.settings)
      #Ecto.Query<...>

  """
  @spec new_follower_notifications_enabled(any()) :: Macro.t()
  defmacro new_follower_notifications_enabled(settings) do
    quote do
      fragment("(?->'notifications'->>'new_followers')::boolean = true", unquote(settings))
    end
  end
end
