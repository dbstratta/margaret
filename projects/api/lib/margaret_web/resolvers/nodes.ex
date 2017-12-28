defmodule MargaretWeb.Resolvers.Nodes do
  @moduledoc """
  The Node GraphQL resolvers.
  """

  alias Margaret.{Accounts, Stories, Publications, Comments}
  alias Accounts.User
  alias Stories.Story
  alias Publications.{Publication, PublicationInvitation}
  alias Comments.Comment

  @doc """
  Resolves the type of the resolved object.
  """
  def resolve_type(%User{}, _), do: :user
  def resolve_type(%Story{}, _), do: :story
  def resolve_type(%Publication{}, _), do: :publication
  def resolve_type(%PublicationInvitation{}, _), do: :publication_invitation
  def resolve_type(%Comment{}, _), do: :comment
  def resolve_type(_, _), do: nil

  @doc """
  Resolves the node from its type and global ID.
  """
  def resolve_node(%{type: :user, id: id}, _), do: {:ok, Accounts.get_user(id)}

  def resolve_node(%{type: :story, id: story_id}, %{context: %{viewer: %User{} = viewer}}) do
    case Stories.can_see_story?(story_id, viewer) do
      {true, story} -> {:ok, story}
      {false, _} -> {:ok, nil}
    end
  end

  def resolve_node(%{type: :story, id: story_id}, _) do
    case Stories.is_story_public?(story_id) do
      {true, story} -> {:ok, story}
      {false, _} -> {:ok, nil}
    end
  end

  def resolve_node(%{type: :publication, id: id}, _) do
    {:ok, Publications.get_publication(id)}
  end

  def resolve_node(%{type: :publication_invitation, id: id}, _) do
    {:ok, Publications.get_publication_invitation(id)}
  end 
end
