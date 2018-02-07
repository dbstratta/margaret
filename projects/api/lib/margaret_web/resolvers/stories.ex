defmodule MargaretWeb.Resolvers.Stories do
  @moduledoc """
  The Story GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Stars, Bookmarks, Publications, Comments}
  alias Accounts.User
  alias Stories.{Story, StoryView}
  alias Stars.Star
  alias Comments.Comment

  @doc """
  Resolves a story by its unique hash.
  """
  def resolve_story(%{unique_hash: unique_hash}, _) do
    story = Stories.get_story_by_unique_hash(unique_hash)

    {:ok, story}
  end

  @doc """
  Resolves the title of the story.
  """
  def resolve_title(story, _, _) do
    title = Stories.get_title(story)

    {:ok, title}
  end

  @doc """
  Resolves the authro of the story.
  """
  def resolve_author(story, _, _) do
    author = Stories.get_author(story)

    {:ok, author}
  end

  @doc """
  Resolves the slug of the story.
  """
  def resolve_slug(story, _, _) do
    slug = Stories.get_slug(story)

    {:ok, slug}
  end

  @doc """
  Resolves the publication of the story.
  """
  def resolve_publication(story, _, _) do
    publication = Stories.get_publication(story)

    {:ok, publication}
  end

  def resolve_tags(story, _, _) do
    tags = Stories.get_tags(story)

    {:ok, tags}
  end

  @doc """
  Resolves the read time of the story.
  """
  def resolve_read_time(story, _, _) do
    read_time = Stories.get_read_time(story)

    {:ok, read_time}
  end

  @doc """
  Resolves a connection of stories.

  TODO: Create a macro `get_popularity` that calculates
  freshness, stars and views.
  """
  def resolve_feed(args, _) do
    query =
      from(
        story in Story,
        left_join: star in Star,
        on: star.story_id == story.id,
        left_join: view in StoryView,
        on: view.story_id == story.id,
        group_by: story.id,
        order_by: [desc: count(star.id)]
      )

    # TODO: Only count stories in that feed.
    total_count = Stories.get_story_count()

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves the stargazers of the story.
  """
  def resolve_stargazers(story, args, _) do
    query =
      User
      |> User.active()
      |> join(:inner, [u], s in assoc(u, :stars))
      |> Star.by_story(story)
      |> select([u, s], {u, %{starred_at: s.inserted_at}})

    total_count = Stories.get_star_count(story)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  def resolve_comments(story, args, _) do
    query =
      Comment
      |> Comment.by_story(story)
      |> join(:inner, [c], u in assoc(c, :author))
      |> User.active()

    total_count = Stories.get_comment_count(story)

    query
    |> Relay.Connection.from_query(&Repo.all/1, args)
    |> Helpers.transform_connection(total_count: total_count)
  end

  @doc """
  Resolves whether the viewer can star the story.
  """
  def resolve_viewer_can_star(_, _, _), do: {:ok, true}

  @doc """
  Resolves whether the viewer has starred this story.
  """
  def resolve_viewer_has_starred(story, _, %{context: %{viewer: viewer}}) do
    has_starred = Stars.has_starred?(user: viewer, story: story)

    {:ok, has_starred}
  end

  @doc """
  Resolves whether the viewer can bookmark the story.
  """
  def resolve_viewer_can_bookmark(_, _, _), do: {:ok, true}

  def resolve_viewer_has_bookmarked(story, _, %{context: %{viewer: viewer}}) do
    has_bookmarked = Bookmarks.has_bookmarked?(user: viewer, story: story)

    {:ok, has_bookmarked}
  end

  @doc """
  Resolves whether the viewer can comment the story.
  """
  def resolve_viewer_can_comment(_, _, _), do: {:ok, true}

  @doc """
  Resolves whether the viewer can update the story.
  """
  def resolve_viewer_can_update(story, _, %{context: %{viewer: viewer}}) do
    can_update_story = Stories.can_update_story?(story, viewer)

    {:ok, can_update_story}
  end

  @doc """
  Resolves whether the viewer can delete the story.
  """
  def resolve_viewer_can_delete(%Story{id: author_id}, _, %{context: %{viewer: %{id: author_id}}}) do
    {:ok, true}
  end

  @doc """
  Resolves a story creation.
  """
  def resolve_create_story(%{publication_id: publication_id} = args, %{
        context: %{viewer: %{id: viewer_id}}
      }) do
    # If the user wants to create the story under a publication,
    # we have to check that they have permission.
    publication_id
    |> Publications.can_write_stories?(viewer_id)
    |> do_resolve_create_story(args, viewer_id)
  end

  def resolve_create_story(args, %{context: %{viewer: %{id: viewer_id}}}) do
    # If there's no publication, we can safely create the story.
    do_resolve_create_story(true, args, viewer_id)
  end

  defp do_resolve_create_story(true, args, author_id) do
    args
    |> Map.put(:author_id, author_id)
    |> Stories.insert_story()
    |> case do
      {:ok, %{story: story}} -> {:ok, %{story: story}}
      {:ok, story} -> {:ok, %{story: story}}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp do_resolve_create_story(false, _, _), do: Helpers.GraphQLErrors.unauthorized()

  @doc """
  Resolves a story update.
  """
  def resolve_update_story(%{story_id: story_id} = args, %{context: %{viewer: %User{} = viewer}}) do
    attrs = Map.delete(args, :story_id)

    case Stories.get_story(story_id) do
      %Story{} = story ->
        story
        |> Stories.can_update_story?(viewer)
        |> do_resolve_update_story(story, attrs)

      _ ->
        {:error, "Story doesn't exist."}
    end
  end

  defp do_resolve_update_story(true, story, attrs) do
    case Stories.update_story(story, attrs) do
      {:ok, %{story: story}} -> {:ok, %{story: story}}
      {:error, _, %Ecto.Changeset{} = changeset, _} -> {:error, changeset}
    end
  end

  defp do_resolve_update_story(false, _, _), do: Helpers.GraphQLErrors.unauthorized()

  @doc """
  Resolves a story deletion.
  """
  def resolve_delete_story(%{story_id: story_id}, %{context: %{viewer: viewer}}) do
    case Stories.get_story(story_id) do
      %Story{} = story -> do_resolve_delete_story(story, viewer)
      _ -> {:error, "Story doesn't exist."}
    end
  end

  defp do_resolve_delete_story(%Story{} = story, viewer) do
    story
    |> Stories.can_delete_story?(viewer)
    |> do_resolve_delete_story(story)
  end

  defp do_resolve_delete_story(true, story) do
    case Stories.delete_story(story) do
      {:ok, _} -> {:ok, %{story: story}}
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp do_resolve_delete_story(false, _), do: Helpers.GraphQLErrors.unauthorized()
end
