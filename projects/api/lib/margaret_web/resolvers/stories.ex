defmodule MargaretWeb.Resolvers.Stories do
  @moduledoc """
  The Story GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Accounts, Stories, Stars, Publications, Comments}
  alias Accounts.User
  alias Stories.Story
  alias Comments.Comment

  @doc """
  Resolves a story by its slug.
  """
  def resolve_story(%{slug: slug}, _), do: {:ok, Stories.get_story_by_slug(slug)}

  @doc """
  Resolves the publication of the story
  """
  def resolve_publication(%Story{publication_id: nil}, _, _), do: {:ok, nil}

  def resolve_publication(%Story{publication_id: publication_id}, _, _) do
    {:ok, Publications.get_publication(publication_id)}
  end

  @doc """
  Resolves a connection of stories.
  """
  def resolve_stories(args, _) do
    Relay.Connection.from_query(Story, &Repo.all/1, args)
  end

  @doc """
  Resolves the star count of the story.
  """
  def resolve_star_count(%Story{id: story_id}, _, _) do
    {:ok, Stars.get_star_count(%{story_id: story_id})}
  end

  def resolve_comments(%Story{id: story_id}, args, _) do
    query = from c in Comment,
      where: c.story_id == ^story_id,
      select: c

    Relay.Connection.from_query(query, &Repo.all/1, args)
  end

  @doc """
  Resolves whether the viewer can star the story or not.
  """
  def resolve_viewer_can_star(_, _, %{context: %{user: nil}}), do: {:ok, false}
  def resolve_viewer_can_star(_, _, %{context: %{user: user}}), do: {:ok, true}

  @doc """
  Resolves whether the viewer can comment the story or not.
  """
  def resolve_viewer_can_comment(_, _, %{context: %{user: nil}}), do: {:ok, false}
  def resolve_viewer_can_comment(_, _, %{context: %{user: user}}), do: {:ok, true}

  @doc """
  Resolves a story creation.
  """
  def resolve_create_story(_, %{context: %{user: nil}}), do: Helpers.GraphQLErrors.unauthorized()

  def resolve_create_story(%{publication_id: p_id} = args, %{context: %{user: %{id: user_id}}}) do
    case Publications.can_write_stories?(p_id, user_id) do
      true -> do_resolve_create_story(args, user_id)
      _ -> Helpers.GraphQLErrors.unauthorized()
    end
  end

  def resolve_create_story(args, %{context: %{user: %{id: user_id}}}) do
    do_resolve_create_story(args, user_id)
  end

  defp do_resolve_create_story(args, author_id) do
    args
    |> Map.put(:author_id, author_id)
    |> Stories.create_story()
    |> case do
      {:ok, story} -> {:ok, %{story: story}}
      {:error, changeset} -> Helpers.GraphQLErrors.something_went_wrong()
    end
  end

  @doc """
  Resolves a story update.
  """
  def resolve_update_story(_args, %{context: %{user: nil}}) do
    Helpers.GraphQLErrors.unauthorized()
  end 

  def resolve_update_story(args, %{context: %{user: user}}) do
    Helpers.GraphQLErrors.not_implemented()
  end 

  @doc """
  Resolves a story deletion.
  """
  def resolve_delete_story(_, %{context: %{user: nil}}), do: Helpers.GraphQLErrors.unauthorized()

  def resolve_delete_story(%{story_id: id}, %{context: %{user: %{id: user_id}}}) do
    with %Story{id: story_id, author_id: author_id} = story <- Stories.get_story(id),
         true <- author_id === user_id,
         {:ok, _} <- Stories.delete_story(story_id) do
      {:ok, %{story: story}}
    else
      nil -> Helpers.GraphQLErrors.error_creator("Story with id #{id} doesn't exist")
      false -> Helpers.GraphQLErrors.unauthorized()
      {:error, _} -> Helpers.GraphQLErrors.something_went_wrong()
    end
  end
end
