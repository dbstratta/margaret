defmodule Margaret.StoryInsertion do
  @moduledoc """
  The Story Insertion context.
  """

  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Publications,
    Collections,
    Notifications,
    Tags,
    Workers
  }

  alias Accounts.User
  alias Stories.Story
  alias Publications.Publication
  alias Collections.Collection

  @doc """
  Inserts a story.

  ## Examples

      iex> insert_story(attrs)
      {:ok, changes}

      iex> insert_story(attrs)
      {:error, :story, %Ecto.Changeset{}, changes}

  """
  def insert_story(attrs) do
    Multi.new()
    |> maybe_insert_tags(attrs)
    |> insert_story(attrs)
    |> maybe_insert_in_collection(attrs)
    |> maybe_notify_users_of_new_story(attrs)
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

  @spec insert_story(Multi.t(), map()) :: Multi.t()
  defp insert_story(multi, attrs) do
    insert_story_fn = fn changes ->
      attrs
      |> maybe_put_tags_structs_in_attrs(changes)
      |> Story.changeset()
      |> maybe_check_publication_permission()
      |> Repo.insert()
    end

    Multi.run(multi, :story, insert_story_fn)
  end

  @spec maybe_put_tags_structs_in_attrs(map(), map()) :: map()
  defp maybe_put_tags_structs_in_attrs(attrs, changes) do
    case changes do
      %{tags: tags} when is_list(tags) -> Map.put(attrs, :tags, tags)
      _ -> attrs
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
        # If it didn't find something, we delegate the error handling to Ecto.
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

  defp maybe_insert_in_collection(multi, attrs) do
    attrs
    |> Map.get(:collection_id)
    |> case do
      collection_id when not is_nil(collection_id) ->
        insert_in_collection(multi, collection_id)

      nil ->
        multi
    end
  end

  defp insert_in_collection(multi, collection_id) do
    insert_in_collection = fn %{story: story} ->
      with %Collection{} = collection <- Collections.get_collection(collection_id),
           author = Stories.author(story),
           :ok <- Bodyguard.permit(Collections, :add_stories, author, collection) do
        Collections.add_story(collection, story)
      else
        nil -> {:error, "Collection not found"}
        {:error, _reason} = error -> error
      end
    end

    Multi.run(multi, :collection, insert_in_collection)
  end

  @spec maybe_notify_users_of_new_story(Multi.t(), map()) :: Multi.t()
  defp maybe_notify_users_of_new_story(multi, %{published_at: published_at})
       when not is_nil(published_at) do
    case NaiveDateTime.compare(published_at, NaiveDateTime.utc_now()) do
      comp when comp in [:lt, :eq] ->
        notify_users_of_new_story(multi)

      :gt ->
        Workers.Notifications.NewStory.enqueue_notification(multi)
    end
  end

  defp maybe_notify_users_of_new_story(multi, _attrs), do: multi

  def notify_users_of_new_story(multi) do
    insert_notification_fn = fn %{story: story} = _changes ->
      notified_users = Stories.Notifications.notifiable_users_of_new_story(story)
      insert_notification(story, notified_users)
    end

    Multi.run(multi, :notify_users_of_new_story, insert_notification_fn)
  end

  defp insert_notification(story, notified_users) do
    attrs = %{
      actor_id: story.author_id,
      action: "added",
      story_id: story.id,
      notified_users: notified_users
    }

    case Notifications.insert_notification(attrs) do
      {:ok, %{notification: notification}} -> {:ok, notification}
      {:error, _, reason, _} -> {:error, reason}
    end
  end
end
