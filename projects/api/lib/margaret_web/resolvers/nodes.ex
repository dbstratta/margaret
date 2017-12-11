defmodule MargaretWeb.Resolvers.Nodes do
  @moduledoc """
  The Node GraphQL resolvers.
  """

  alias Margaret.{Accounts, Stories}
  alias Accounts.User
  alias Stories.Story
  alias MargaretWeb.Resolvers

  @doc """
  Resolves the type of the resolved object.
  """
  def resolve_type(%User{}, _), do: :user
  def resolve_type(%Story{}, _), do: :story
  def resolve_type(_, _), do: nil

  @doc """
  Resolves the node from its type and global ID.
  """
  def resolve_node(%{type: :user, id: id}, _), do: {:ok, Accounts.get_user(id)}
  def resolve_node(%{type: :story, id: id}, _), do: {:ok, Stories.get_story(id)}
end
