defmodule MargaretWeb.Resolvers.Stories do
  @moduledoc """
  The Story GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.{Repo, Stories}
  alias Margaret.Accounts.User
  alias Stories.Story

  @doc """
  Resolves a story by its slug.
  """
  def resolve_story(%{slug: slug}, _), do: {:ok, Stories.get_story_by_slug(slug)}

  @doc """
  Resolves a connection of stories.
  """
  def resolve_stories(args, _) do
    Relay.Connection.from_query(Story, &Repo.all/1, args)
  end

  @doc """
  Resolves a connection of stories of a parent.
  """
  def resolve_stories(%User{} = user, args, _) do
    Story
    |> where(author_id: ^user.id)
    |> Relay.Connection.from_query(&Repo.all/1, args)
  end

  @doc """
  Resolves a story creation.
  """
  def resolve_create_story(_, %{context: %{user: nil}}), do: Helpers.GraphQLErrors.unauthorized()

  def resolve_create_story(args, %{context: %{user: %{id: user_id}}}) do
    args
    |> Map.put(:author_id, user_id)
    |> Stories.create_story()
    |> case do
      {:ok, story} -> {:ok, %{story: story}}
      {:error, changeset} -> Helpers.GraphQLErrors.something_went_wrong()
    end
  end

  @doc """
  Resolves a story deletion.
  """
  def resolve_delete_story(_, %{context: %{user: nil}}), do: Helpers.GraphQLErrors.unauthorized()

  def resolve_delete_story(%{story_id: id}, %{context: %{user: %{id: user_id}}}) do
    with %Story{id: story_id, author_id: author_id} <- Stories.get_story(id),
         true <- author_id === user_id,
         {:ok, story} <- Stories.delete_story(story_id) do
      {:ok, %{story: story}}
    else
      nil -> Helpers.GraphQLErrors.error_creator("Story with id #{id} doesn't exist")
      false -> Helpers.GraphQLErrors.unauthorized()
      {:error, _} -> Helpers.GraphQLErrors.something_went_wrong()
    end
  end
end
