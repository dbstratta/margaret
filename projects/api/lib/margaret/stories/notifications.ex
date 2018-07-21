defmodule Margaret.Stories.Notifications do
  @moduledoc """

  """

  import Ecto.Query

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    UserSettings
  }

  alias Accounts.User
  alias Stories.Story

  import UserSettings

  @doc """
  Returns the list of notifiable users for a new story.

  ## Examples

      iex> notifiable_users_of_new_story(%Story{})
      [%User{}, %User{}]

  """
  @spec notifiable_users_of_new_story(Story.t()) :: [User.t()]
  def notifiable_users_of_new_story(%Story{} = story) do
    active_users_query = Accounts.Queries.users()
    following_publication = following_publication(story)

    notifiable_users_query =
      from u in active_users_query,
        join: f in Follow,
        on: f.follower_id == u.id,
        where: f.user_id == ^story.author_id,
        or_where: ^following_publication,
        group_by: u.id,
        having: new_story_notifications_enabled(u.settings)

    Repo.all(notifiable_users_query)
  end

  defp following_publication(story) do
    if Stories.under_publication?(story) do
      dynamic([..., f], f.publication_id == ^story.publication_id)
    else
      false
    end
  end
end
