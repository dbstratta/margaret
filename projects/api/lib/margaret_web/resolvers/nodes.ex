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

  def resolve_node(%{type: :story, id: id}, _), do: {:ok, Stories.get_story(id)}

  def resolve_node(%{type: :publication, id: id}, _) do
    {:ok, Publications.get_publication(id)}
  end

  def resolve_node(%{type: :publication_invitation, id: id}, _) do
    {:ok, Publications.get_publication_invitation(id)}
  end 
end
