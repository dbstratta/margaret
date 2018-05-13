defmodule MargaretWeb.Resolvers.Stories do
  @moduledoc """
  The Story GraphQL resolvers.
  """

  import MargaretWeb.Helpers, only: [ok: 1]
  alias MargaretWeb.Helpers

  alias Margaret.{
    Accounts,
    Stories,
    Stars,
    Bookmarks,
    Publications,
    Comments
  }

  alias Accounts.User
  alias Stories.Story

  @doc """
  Resolves a story by its unique hash.
  """
  @spec resolve_story(map(), Absinthe.Resolution.t()) :: {:ok, Story.t() | nil}
  def resolve_story(%{unique_hash: unique_hash}, _) do
    unique_hash
    |> Stories.get_story_by_unique_hash()
    |> ok()
  end

  @doc """
  Resolves the title of the story.
  """
  @spec resolve_title(Story.t(), map(), Absinthe.Resolution.t()) :: {:ok, String.t()}
  def resolve_title(story, _, _) do
    story
    |> Stories.title()
    |> ok()
  end

  @doc """
  Resolves the authro of the story.
  """
  @spec resolve_author(Story.t(), map(), Absinthe.Resolution.t()) :: {:ok, User.t()}
  def resolve_author(story, _, _) do
    story
    |> Stories.author()
    |> ok()
  end

  @doc """
  Resolves the slug of the story.
  """
  @spec resolve_slug(Story.t(), map(), Absinthe.Resolution.t()) :: {:ok, String.t()}
  def resolve_slug(story, _, _) do
    story
    |> Stories.slug()
    |> ok()
  end

  @doc """
  Resolves the summary of the story.
  """
  @spec resolve_summary(Story.t(), map(), Absinthe.Resolution.t()) :: {:ok, String.t()}
  def resolve_summary(story, _, _) do
    story
    |> Stories.summary()
    |> ok()
  end

  @doc """
  Resolves the publication of the story.
  """
  @spec resolve_publication(Story.t(), map(), Absinthe.Resolution.t()) ::
          {:ok, Publication.t() | nil}
  def resolve_publication(story, _args, _resolution) do
    story
    |> Stories.publication()
    |> ok()
  end

  @spec resolve_tags(Story.t(), map(), Absinthe.Resolution.t()) :: {:ok, [Tag.t()]}
  def resolve_tags(story, _args, _resolution) do
    story
    |> Stories.tags()
    |> ok()
  end

  @doc """
  Resolves the read time of the story.
  """
  @spec resolve_read_time(Story.t(), map(), Absinthe.Resolution.t()) :: {:ok, pos_integer()}
  def resolve_read_time(story, _args, _resolution) do
    story
    |> Stories.read_time()
    |> ok()
  end

  @doc """
  Resolves a connection of stories.
  """
  def resolve_feed(args, _resolution) do
    args
    |> Stories.stories()
  end

  @doc """
  Resolves the stargazers of the story.
  """
  def resolve_stargazers(story, args, _resolution) do
    args
    |> Map.put(:story, story)
    |> Stars.stargazers()
  end

  def resolve_comments(story, args, _resolution) do
    args
    |> Map.put(:story, story)
    |> Comments.comments()
  end

  def resolve_is_under_publication(story, _args, _resolution) do
    story
    |> Stories.under_publication?()
    |> ok()
  end

  @doc """
  Resolves whether the viewer can star the story.
  """
  def resolve_viewer_can_star(_story, _args, _resolution), do: ok(true)

  @doc """
  Resolves whether the viewer has starred this story.
  """
  def resolve_viewer_has_starred(story, _args, %{context: %{viewer: viewer}}) do
    [user: viewer, story: story]
    |> Stars.has_starred?()
    |> ok()
  end

  @doc """
  Resolves whether the viewer can bookmark the story.
  """
  def resolve_viewer_can_bookmark(_story, _args, _resolution), do: ok(true)

  def resolve_viewer_has_bookmarked(story, _args, %{context: %{viewer: viewer}}) do
    [user: viewer, story: story]
    |> Bookmarks.has_bookmarked?()
    |> ok()
  end

  @doc """
  Resolves whether the viewer can comment the story.
  """
  def resolve_viewer_can_comment(_story, _args, _resolution), do: ok(true)

  @doc """
  Resolves whether the viewer can update the story.
  """
  def resolve_viewer_can_update(story, _, %{context: %{viewer: viewer}}) do
    story
    |> Stories.can_update_story?(viewer)
    |> ok()
  end

  @doc """
  Resolves whether the viewer can delete the story.
  """
  def resolve_viewer_can_delete(%Story{id: author_id}, _, %{context: %{viewer: %{id: author_id}}}) do
    ok(true)
  end

  @doc """
  Resolves a story creation.
  """
  def resolve_create_story(%{publication_id: publication_id} = args, %{
        context: %{viewer: viewer}
      }) do
    # If the user wants to create the story under a publication,
    # we have to check that they have permission.
    publication_id
    |> Publications.can_write_stories?(viewer)
    |> do_resolve_create_story(args, viewer)
  end

  def resolve_create_story(args, %{context: %{viewer: viewer}}) do
    # If there's no publication, we can safely create the story.
    do_resolve_create_story(true, args, viewer)
  end

  defp do_resolve_create_story(true, args, %User{id: author_id}) do
    args
    |> Map.put(:author_id, author_id)
    |> maybe_update_published_at()
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
        Helpers.GraphQLErrors.story_not_found()
    end
  end

  defp do_resolve_update_story(true, story, attrs) do
    attrs = maybe_update_published_at(attrs)

    case Stories.update_story(story, attrs) do
      {:ok, %{story: story}} -> {:ok, %{story: story}}
      {:error, _, %Ecto.Changeset{} = changeset, _} -> {:error, changeset}
    end
  end

  defp do_resolve_update_story(false, _, _), do: Helpers.GraphQLErrors.unauthorized()

  # If the key `publish_now` is present in the attributes,
  # delete it and put `published_at` with the current time.
  @spec maybe_update_published_at(map()) :: map()
  defp maybe_update_published_at(%{publish_now: true} = attrs) do
    attrs
    |> Map.delete(:publish_now)
    |> Map.put(:published_at, NaiveDateTime.utc_now())
  end

  defp maybe_update_published_at(attrs), do: attrs

  @doc """
  Resolves a story view.
  """
  def resolve_view_story(%{story_id: story_id}, %{context: context}) do
    with %Story{} = story <- Stories.get_story(story_id),
         viewer = Map.get(context, :viewer),
         {:ok, _} <- Stories.view_story(story: story, viewer: viewer) do
      ok(story)
    else
      nil -> Helpers.GraphQLErrors.story_not_found()
      {:error, _} -> Helpers.GraphQLErrors.something_went_wrong()
    end
  end

  @doc """
  Resolves a story deletion.
  """
  def resolve_delete_story(%{story_id: story_id}, %{context: %{viewer: viewer}}) do
    case Stories.get_story(story_id) do
      %Story{} = story -> do_resolve_delete_story(story, viewer)
      _ -> Helpers.GraphQLErrors.story_not_found()
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
