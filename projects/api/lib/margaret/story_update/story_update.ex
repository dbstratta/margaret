defmodule Margaret.StoryUpdate do
  @moduledoc """
  The Story Update context.
  """

  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Publications,
    StoryInsertion,
    Tags,
    Workers
  }

  alias Accounts.User
  alias Stories.Story
  alias Publications.Publication

  def update_story(%Story{} = story, attrs) do
    Multi.new()
    |> maybe_insert_tags(attrs)
    |> update_story(story, attrs)
    |> maybe_notify_users_of_new_story(story, attrs)
    |> Repo.transaction()
  end

  @spec maybe_insert_tags(Multi.t(), map()) :: Multi.t()
  defp maybe_insert_tags(multi, attrs) do
    case attrs do
      %{tags: tag_titles} when is_list(tag_titles) ->
        Tags.insert_and_get_all_tags_multi(multi, tag_titles)

      _ ->
        multi
    end
  end

  @spec update_story(Multi.t(), Story.t(), map()) :: Multi.t()
  defp update_story(multi, %Story{} = story, attrs) do
    # It's not possible to change the publication of a story
    # after the latter has been published.

    update_story_fn = fn changes ->
      attrs = maybe_put_tag_structs_in_attrs(attrs, changes)

      story
      |> maybe_preload_tags(attrs)
      |> Story.update_changeset(attrs)
      |> maybe_authorize_publication_change()
      |> maybe_check_publication_permission()
      |> Repo.update()
    end

    Multi.run(multi, :story, update_story_fn)
  end

  defp maybe_put_tag_structs_in_attrs(attrs, changes) do
    case changes do
      %{tags: tags} -> Map.put(attrs, :tags, tags)
      _ -> attrs
    end
  end

  defp maybe_preload_tags(story, attrs) do
    if Map.has_key?(attrs, :tags) do
      Repo.preload(story, :tags)
    else
      story
    end
  end

  defp maybe_authorize_publication_change(%{data: story} = changeset) do
    if publication_change?(changeset) and Stories.has_been_published?(story) do
      Ecto.Changeset.add_error(
        changeset,
        :publication_id,
        """
        Cannot change publication
        after the story has been published
        """
      )
    else
      changeset
    end
  end

  defp publication_change?(changeset) do
    case Ecto.Changeset.fetch_change(changeset, :publication_id) do
      {:ok, _} -> true
      :error -> false
    end
  end

  defp maybe_check_publication_permission(changeset) do
    changeset
    |> Ecto.Changeset.get_change(:publication_id)
    |> case do
      nil ->
        changeset

      publication_id ->
        check_publication_permission(changeset, publication_id)
    end
  end

  defp check_publication_permission(changeset, publication_id) do
    with %Publication{} = publication <- Publications.get_publication(publication_id),
         %User{} = author <- get_author_from_changeset(changeset),
         :ok <- Bodyguard.permit(Publications, :write_story, author, publication) do
      changeset
    else
      nil ->
        changeset

      {:error, reason} ->
        Ecto.Changeset.add_error(changeset, :publication_id, reason)
    end
  end

  defp get_author_from_changeset(changeset) do
    changeset
    |> Ecto.Changeset.get_field(:author_id)
    |> Accounts.get_user()
  end

  @spec maybe_notify_users_of_new_story(Multi.t(), Story.t(), map()) :: Multi.t()
  defp maybe_notify_users_of_new_story(multi, %Story{} = story, attrs) do
    cond do
      Stories.has_been_published?(story) ->
        multi

      Map.has_key?(attrs, :published_at) ->
        notify_users_of_new_story_or_schedule_notification(
          multi,
          attrs.published_at
        )

      true ->
        multi
    end
  end

  defp notify_users_of_new_story_or_schedule_notification(multi, published_at) do
    case NaiveDateTime.compare(published_at, NaiveDateTime.utc_now()) do
      comparison when comparison in [:lt, :eq] ->
        StoryInsertion.notify_users_of_new_story(multi)

      :gt ->
        Workers.Notifications.NewStory.enqueue_notification(multi)
    end
  end
end
