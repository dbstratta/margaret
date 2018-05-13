defmodule MargaretWeb.Resolvers.Nodes do
  @moduledoc """
  The Node GraphQL resolvers.
  """

  import MargaretWeb.Helpers, only: [ok: 1]

  alias Margaret.{Accounts, Stories, Publications, Collections, Comments, Notifications, Tags}
  alias Accounts.User
  alias Stories.Story
  alias Publications.{Publication, PublicationInvitation}
  alias Collections.Collection
  alias Comments.Comment
  alias Notifications.Notification
  alias Tags.Tag
  alias MargaretWeb.Helpers

  @doc """
  Resolves the type of the resolved object.
  """
  def resolve_type(%User{}, _), do: :user
  def resolve_type(%Story{}, _), do: :story
  def resolve_type(%Publication{}, _), do: :publication
  def resolve_type(%PublicationInvitation{}, _), do: :publication_invitation
  def resolve_type(%Collection{}, _), do: :collection
  def resolve_type(%Comment{}, _), do: :comment
  def resolve_type(%Notification{}, _), do: :notification
  def resolve_type(%Tag{}, _), do: :tag
  def resolve_type(_, _), do: nil

  @doc """
  Resolves the node from its type and global ID.
  """
  def resolve_node(%{type: :user, id: user_id}, _) do
    user_id
    |> Accounts.get_user()
    |> ok()
  end

  def resolve_node(%{type: :story, id: story_id}, %{context: %{viewer: viewer}}) do
    with %Story{} = story <- Stories.get_story(story_id),
         true <- Stories.can_see_story?(story, viewer) do
      ok(story)
    else
      nil -> Helpers.GraphQLErrors.story_not_found()
      false -> Helpers.GraphQLErrors.unauthorized()
    end
  end

  def resolve_node(%{type: :story, id: story_id}, _) do
    with %Story{} = story <- Stories.get_story(story_id),
         true <- Stories.public?(story) do
      ok(story)
    else
      nil -> Helpers.GraphQLErrors.story_not_found()
      false -> Helpers.GraphQLErrors.unauthorized()
    end
  end

  def resolve_node(%{type: :publication, id: publication_id}, _) do
    publication_id
    |> Publications.get_publication()
    |> ok()
  end

  def resolve_node(%{type: :publication_invitation, id: invitation_id}, _) do
    invitation_id
    |> Publications.get_invitation()
    |> ok()
  end

  def resolve_node(%{type: :collection, id: collection_id}, _) do
    collection_id
    |> Collections.get_collection()
    |> ok()
  end

  def resolve_node(%{type: :comment, id: comment_id}, %{context: %{viewer: viewer}}) do
    with %Comment{} = comment <- Comments.get_comment(comment_id),
         true <- Comments.can_see_comment?(comment, viewer) do
      ok(comment)
    else
      nil -> Helpers.GraphQLErrors.comment_not_found()
      false -> Helpers.GraphQLErrors.unauthorized()
    end
  end

  def resolve_node(%{type: :comment, id: comment_id}, _) do
    with %Comment{} = comment <- Comments.get_comment(comment_id),
         true <- Comments.public?(comment) do
      ok(comment)
    else
      nil -> Helpers.GraphQLErrors.comment_not_found()
      false -> Helpers.GraphQLErrors.unauthorized()
    end
  end

  def resolve_node(%{type: :tag, id: tag_id}, _) do
    tag_id
    |> Tags.get_tag()
    |> ok()
  end
end
