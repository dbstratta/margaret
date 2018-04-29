defmodule Margaret.Stories do
  @moduledoc """
  The Stories context.
  """

  import Ecto.Query
  alias Ecto.Multi

  alias Margaret.{
    Repo,
    Accounts,
    Stories,
    Comments,
    Stars,
    Publications,
    Collections,
    Follows,
    Notifications,
    Tags,
    Workers
  }

  alias Accounts.User
  alias Stories.{Story, StoryView}
  alias Publications.Publication
  alias Collections.Collection
  alias Follows.Follow

  import User

  @doc """
  Gets a single story by its id.

  ## Examples

      iex> get_story(123)
      %Story{}

      iex> get_story(456)
      nil

  """
  @spec get_story(String.t() | non_neg_integer()) :: Story.t() | nil
  def get_story(id), do: Repo.get(Story, id)

  @doc """
  Gets a single story by its id.

  Raises `Ecto.NoResultsError` if the Story does not exist.

  ## Examples

      iex> get_story!(123)
      %Story{}

      iex> get_story!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_story!(String.t() | non_neg_integer()) :: Story.t() | no_return()
  def get_story!(id), do: Repo.get!(Story, id)

  @doc """
  Gets a story by its slug.

  ## Examples

      iex> get_story_by_slug("slug-234abfe")
      %Story{}

      iex> get_story_by_slug("slug-456a3be")
      nil

  """
  @spec get_story_by_slug(String.t()) :: Story.t() | nil
  def get_story_by_slug(slug) do
    slug
    |> String.split("-")
    |> List.last()
    |> get_story_by_unique_hash()
  end

  @doc """
  Gets a story by its unique_hash.

  ## Examples

      iex> get_story_by_unique_hash("a324b897c")
      %Story{}

      iex> get_story_by_unique_hash("jksdf234")
      nil

  """
  @spec get_story_by_unique_hash(String.t()) :: Story.t() | nil
  def get_story_by_unique_hash(unique_hash), do: get_story_by(unique_hash: unique_hash)

  @doc """
  Gets a story by given clauses.

  ## Examples

      iex> get_story_by(unique_hash: "abs2375cf")
      %Story{}

  """
  @spec get_story_by(Keyword.t()) :: Story.t() | nil
  def get_story_by(clauses), do: Repo.get_by(Story, clauses)

  @doc """
  Gets the title of a story.

  ## Examples

      iex> title(%Story{})
      "Title"

  """
  @spec title(Story.t()) :: String.t()
  def title(%Story{content: %{"blocks" => [%{"text" => title} | _]}}), do: title

  @doc """
  Gets the slug of a story.

  ## Examples

      iex> slug(%Story{})
      "title-abc123ba"

  """
  @spec slug(Story.t()) :: String.t()
  def slug(%Story{unique_hash: unique_hash} = story) do
    story
    |> Stories.title()
    |> Slugger.slugify_downcase()
    |> Kernel.<>("-")
    |> Kernel.<>(unique_hash)
  end

  @doc """
  Gets the summary of a story.

  ## Examples

      iex> summary(%Story{})
      "Lorem ipsum."

      iex> summary(%Story{})
      ""

  """
  @spec summary(Story.t()) :: String.t()
  def summary(%Story{content: %{"blocks" => blocks}}) do
    case blocks do
      [_, %{"text" => summary} | _] -> summary
      _ -> ""
    end
  end

  @doc """
  Gets the author of a story.

  ## Examples

      iex> author(%Story{})
      %User{}

  """
  @spec author(Story.t()) :: User.t()
  def author(%Story{} = story) do
    story
    |> Story.preload_author()
    |> Map.fetch!(:author)
  end

  @doc """
  Gets the tags of a story.

  ## Examples

      iex> tags(%Story{})
      [%Tag{}]

  """
  @spec tags(Story.t()) :: [Tag.t()]
  def tags(%Story{} = story) do
    story
    |> Story.preload_tags()
    |> Map.get(:tags)
  end

  @doc """
  Gets the publication of a story.

  ## Examples

      iex> publication(%Story{})
      %Publication{}

      iex> publication(%Story{})
      nil

  """
  @spec publication(Story.t()) :: Publication.t() | nil
  def publication(%Story{} = story) do
    story
    |> Story.preload_publication()
    |> Map.fetch!(:publication)
  end

  @doc """
  Gets the collection of a story.

  ## Examples

      iex> collection(%Story{})
      %Collection{}

      iex> collection(%Story{})
      nil

  """
  @spec collection(Story.t()) :: Collection.t() | nil
  def collection(%Story{} = story) do
    story
    |> Story.preload_collection()
    |> Map.fetch!(:collection)
  end

  @doc """
  Returns the list of notifiable users for a new story.

  ## Examples

      iex> notifiable_users_of_new_story(%Story{})
      [%User{}, %User{}]

  """
  @spec notifiable_users_of_new_story(Story.t()) :: [User.t()]
  def notifiable_users_of_new_story(%Story{} = story) do
    publication_followers =
      if under_publication?(story) do
        dynamic([..., f], f.publication_id == ^story.publication_id)
      else
        false
      end

    query =
      from(
        u in User,
        where: is_nil(u.deactivated_at),
        join: f in Follow,
        on: f.follower_id == u.id,
        where: f.user_id == ^story.author_id,
        or_where: ^publication_followers,
        group_by: u.id,
        having: new_story_notifications_enabled(u.settings)
      )

    Repo.all(query)
  end

  @doc """
  Gets the word count of a story.

  ## Examples

      iex> word_count(%Story{})
      42

  """
  @spec word_count(Story.t()) :: non_neg_integer()
  def word_count(%Story{content: %{"blocks" => blocks}}) do
    blocks
    |> Enum.map_join(" ", &Map.get(&1, "text"))
    |> String.split()
    |> length()
  end

  @doc """
  Gets the read time of a story in minutes.

  ## Examples

      iex> read_time(%Story{})
      12

  """
  @spec read_time(Story.t()) :: non_neg_integer()
  def read_time(%Story{} = story) do
    avg_wpm = 275

    story
    |> word_count()
    |> div(avg_wpm)
    |> case do
      0 -> 1
      read_time -> read_time
    end
  end

  @doc """
  Gets the story count.

  ## Examples

      iex> story_count()
      815

  """
  @spec story_count(Keyword.t()) :: non_neg_integer()
  def story_count(opts \\ []) do
    query =
      if Keyword.get(opts, :published_only, false) do
        Story.published()
      else
        Story
      end

    Repo.count(query)
  end

  @doc """
  Gets the star count of a story.
  """
  @spec star_count(Story.t()) :: non_neg_integer()
  def star_count(%Story{} = story), do: Stars.star_count(story: story)

  @doc """
  Gets the comment count of a story.
  """
  @spec comment_count(Story.t()) :: non_neg_integer()
  def comment_count(%Story{} = story), do: Comments.comment_count(story: story)

  @doc """
  Returns `true` if the story is under a publication.
  """
  @spec under_publication?(Story.t()) :: boolean()
  def under_publication?(%Story{publication_id: nil}), do: false
  def under_publication?(%Story{}), do: true

  @doc """
  Returns `true` if the story is in a collection.
  """
  @spec in_collection?(Story.t()) :: boolean()
  def in_collection?(%Story{} = story), do: !!collection(story)

  @doc """
  Returns `true` if the story has been published.
  `false` otherwise.

  ## Examples

      iex> has_been_published(%Story{})
      false

  """
  @spec has_been_published?(Story.t()) :: boolean()
  def has_been_published?(%Story{published_at: nil}), do: false

  def has_been_published?(%Story{published_at: published_at}),
    do: NaiveDateTime.compare(published_at, NaiveDateTime.utc_now()) === :lt

  @doc """
  Returns `true` if the story is public,
  `false` otherwise.

  Public means that the story is visible by anyone
  and it has been published.

  ## Examples

      iex> public?(%Story{})
      true

      iex> public?(%Story{})
      false

  """
  @spec public?(Story.t()) :: boolean()
  def public?(%Story{audience: :all} = story), do: has_been_published?(story)
  def public?(_), do: false

  @doc """
  Returns `true` if the user can see the story.
  `false` otherwise.

  ## Examples

      iex> can_see_story?(%Story{}, %User{})
      true

  """
  @spec can_see_story?(Story.t(), User.t()) :: boolean()
  def can_see_story?(%Story{author_id: author_id}, %User{id: author_id}), do: true

  def can_see_story?(%Story{publication_id: publication_id}, %User{} = user)
      when not is_nil(publication_id) do
    publication_id
    |> Publications.get_publication()
    |> Publications.can_edit_stories?(user)
  end

  def can_see_story?(%Story{audience: :members} = story, %User{} = user) do
    is_member = Accounts.member?(user)
    has_been_published = has_been_published?(story)

    is_member and has_been_published
  end

  def can_see_story?(%Story{} = story, _user), do: public?(story)

  @doc """
  Returns `true` if the user can update the story,
  `false` otherwise.

  ## Examples

      iex> can_update_story?(%Story{}, %User{})
      true

  """
  @spec can_update_story?(Story.t(), User.t()) :: boolean()
  def can_update_story?(%Story{author_id: author_id}, %User{id: author_id}), do: true

  def can_update_story?(%Story{publication_id: publication_id}, %User{id: user_id})
      when not is_nil(publication_id) do
    Publications.can_edit_stories?(publication_id, user_id)
  end

  def can_update_story?(_, _), do: false

  @doc """
  Returns `true` if the user can delete the story,
  `false` otherwise.

  ## Examples

      iex> can_delete_story?(%Story{}, %User{})
      true

  """
  @spec can_delete_story?(Story.t(), User.t()) :: boolean()
  def can_delete_story?(%Story{author_id: author_id}, %User{id: author_id}), do: true
  def can_delete_story?(_, _), do: false

  @doc """
  Inserts a story.

  ## Examples

      iex> insert_story(attrs)
      {:ok, changes}

      iex> insert_story(attrs)
      {:error, :story, %Ecto.Changeset{}, changes}

  """
  @spec insert_story(map()) :: {:ok, map()} | {:error, atom(), any(), map()}
  def insert_story(attrs) do
    Multi.new()
    |> maybe_insert_tags(attrs)
    |> insert_story(attrs)
    |> maybe_insert_in_collection(attrs)
    |> maybe_notify_users_of_new_story(attrs)
    |> Repo.transaction()
  end

  @spec insert_story(Multi.t(), map()) :: Multi.t()
  defp insert_story(multi, attrs) do
    insert_story_fn = fn changes ->
      # We have the list of tags from a previous step in
      # the transaction, now we have to put that list in the attrs map.
      # This is only if the author added tags to the story
      # in the first place.
      maybe_put_tags = fn attrs ->
        case changes do
          %{tags: tags} -> Map.put(attrs, :tags, tags)
          _ -> attrs
        end
      end

      attrs
      |> maybe_put_tags.()
      |> Story.changeset()
      |> maybe_check_publication_permission()
      |> Repo.insert()
    end

    Multi.run(multi, :story, insert_story_fn)
  end

  # If there's a `collection_id` in the attrs map
  # we try to insert the story in the collection.
  @spec maybe_insert_in_collection(Multi.t(), map()) :: Multi.t()
  defp maybe_insert_in_collection(multi, %{collection_id: collection_id}) do
    insert_in_collection = fn %{story: %Story{id: story_id} = story} ->
      with %Collection{} = collection <- Collections.get_collection(collection_id),
           author = author(story),
           true <- Collections.can_add_stories_to_collection?(collection, author),
           part = Collections.next_part_number(collection),
           attrs = %{collection_id: collection_id, story_id: story_id, part: part} do
        Collections.insert_collection_story(attrs)
      else
        nil -> {:error, "Collection doesn't exist"}
        false -> {:error, "User cannot add stories to the collection"}
      end
    end

    Multi.run(multi, :collection, insert_in_collection)
  end

  defp maybe_insert_in_collection(multi, _attrs), do: multi

  @doc """
  Updates a story.
  """
  @spec update_story(Story.t(), map()) :: {:ok, map()} | {:error, atom(), any(), map()}
  def update_story(%Story{} = story, attrs) do
    Multi.new()
    |> maybe_insert_tags(attrs)
    |> update_story(story, attrs)
    |> maybe_notify_users_of_new_story(story, attrs)
    |> Repo.transaction()
  end

  @spec update_story(Multi.t(), Story.t(), map()) :: Multi.t()
  defp update_story(multi, %Story{} = story, attrs) do
    # It's not possible to change the publication of a story
    # after the latter has been published.
    maybe_validate_publication_change = fn changeset ->
      if has_been_published?(story) do
        case Ecto.Changeset.fetch_change(changeset, :publication_id) do
          # If there is an intent to change the publication.
          {:ok, _} ->
            Ecto.Changeset.add_error(
              changeset,
              :publication_id,
              "Cannot change publication after the story has been published"
            )

          :error ->
            changeset
        end
      else
        changeset
      end
    end

    update_story_fn = fn changes ->
      # We have the list of tags from a previous step in
      # the transaction, now we have to put that list in the attrs map
      # and preload the tags in the story struct.
      # This is only if the author wanted to change the tags
      # of the story in the first place.
      maybe_put_tags = fn {story, attrs} ->
        case changes do
          %{tags: tags} -> {Story.preload_tags(story), Map.put(attrs, :tags, tags)}
          _ -> {story, attrs}
        end
      end

      {story, attrs} = maybe_put_tags.({story, attrs})

      story
      |> Story.update_changeset(attrs)
      |> maybe_validate_publication_change.()
      |> maybe_check_publication_permission()
      |> Repo.update()
    end

    Multi.run(multi, :story, update_story_fn)
  end

  # Check that if the author wants to add the story under
  # a publication, that they have permission to do so.
  defp maybe_check_publication_permission(changeset) do
    changeset
    |> Ecto.Changeset.get_change(:publication_id)
    |> case do
      nil ->
        changeset

      publication_id ->
        with %Publication{} = publication <- Publications.get_publication(publication_id),
             author_id = Ecto.Changeset.get_field(changeset, :author_id),
             %User{} = author <- Accounts.get_user(author_id),
             true <- Publications.can_write_stories?(publication, author) do
          changeset
        else
          # If it doesn't find something, we just let Ecto
          # add the errors to the changeset.
          nil ->
            changeset

          # If the user doesn't have permission to write stories
          # under the publication.
          false ->
            Ecto.Changeset.add_error(changeset, :publication_id, "Unauthorized")
        end
    end
  end

  @spec maybe_insert_tags(Multi.t(), map()) :: Multi.t()
  defp maybe_insert_tags(multi, %{tags: tags}) do
    insert_tags_fn = fn _ ->
      tags = Tags.insert_and_get_all_tags(tags)

      {:ok, tags}
    end

    Multi.run(multi, :tags, insert_tags_fn)
  end

  defp maybe_insert_tags(multi, _attrs), do: multi

  # Notifies the followers of the author or publication if
  # the story is in one that there's a new story.
  @spec maybe_notify_users_of_new_story(Multi.t(), Story.t(), map()) :: Multi.t()
  defp maybe_notify_users_of_new_story(multi, story \\ nil, attrs)

  defp maybe_notify_users_of_new_story(multi, nil, %{published_at: nil}), do: multi

  defp maybe_notify_users_of_new_story(multi, nil, %{published_at: published_at})
       when not is_nil(published_at) do
    # If it is a new story and it is inteded to be published now.
    case NaiveDateTime.compare(published_at, NaiveDateTime.utc_now()) do
      :lt ->
        insert_notification = fn %{story: story} ->
          notified_users = notifiable_users_of_new_story(story)

          notification_attrs = %{
            actor_id: story.author_id,
            action: "added",
            story_id: story.id,
            notified_users: notified_users
          }

          case Notifications.insert_notification(notification_attrs) do
            {:ok, %{notification: notification}} -> {:ok, notification}
            {:error, _, reason, _} -> {:error, reason}
          end
        end

        Multi.run(multi, :notify_users_of_new_story, insert_notification)

      # It's not intended to be published now. So we don't notify anyone.
      _ ->
        multi
    end
  end

  defp maybe_notify_users_of_new_story(multi, %Story{} = story, attrs) do
    cond do
      # If the story has already been published, don't notify anyone.
      has_been_published?(story) ->
        multi

      # If it wasn't published before and it is intended to publish now or
      # to schedule its publication.
      not has_been_published?(story) and Map.has_key?(attrs, :published_at) ->
        case NaiveDateTime.compare(attrs.published_at, NaiveDateTime.utc_now()) do
          # TODO:
          comparison when comparison in [:lt, :eq] ->
            notify_users_fn = fn _ ->
              nil
            end

            Multi.run(multi, :notify_users_of_new_story, notify_users_fn)

          # If the date of publication is in the future, enqueue
          # a notification to be inserted at that time.
          :gt ->
            Workers.Notifications.NewStory.enqueue_notification(multi)
        end

      true ->
        multi
    end
  end

  @doc """
  Inserts a story view.

  ## Examples

      iex> view_story(story: %Story{})
      {:ok, %StoryView{}}

      iex> view_story(story: %Story{}, viewer: %User{})
      {:ok, %StoryView{}}

  """
  @spec view_story(Keyword.t()) :: {:ok, StoryView.t()} | {:error, Ecto.Changeset.t()}
  def view_story(clauses) do
    story_id =
      clauses
      |> Keyword.fetch!(:story)
      |> Map.fetch!(:id)

    viewer_id =
      clauses
      |> Keyword.get(:viewer)
      |> case do
        %User{id: user_id} -> user_id
        nil -> nil
      end

    attrs = %{story_id: story_id, viewer_id: viewer_id}

    insert_story_view(attrs)
  end

  defp insert_story_view(attrs) do
    attrs
    |> StoryView.changeset()
    |> Repo.insert()
  end

  @doc """
  Deletes a story.

  ## Examples

      iex> delete_story(%Story{})
      {:ok, %Story{}}

  """
  @spec delete_story(Story.t()) :: {:ok, Story.t()} | {:error, Ecto.Changeset.t()}
  def delete_story(%Story{} = story), do: Repo.delete(story)
end
