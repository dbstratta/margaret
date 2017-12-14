defmodule MargaretWeb.Resolvers.Publications do
  @moduledoc """
  The Publication GraphQL resolvers.
  """

  alias MargaretWeb.Helpers
  alias Margaret.Publications

  def resolve_publication(%{name: name}, _) do
    {:ok, Publications.get_publication_by_name(name)}
  end

  def resolve_members(_, _, _) do

  end

  def resolve_create_publication(_, %{context: %{user: nil}}) do
    Helpers.GraphQLErrors.unauthorized()
  end

  def resolve_create_publication(args, %{context: %{user: user}}) do
    args
    |> Map.put(:owner_id, user.id)
    |> Publications.create_publication()
    |> case do
      {:ok, publication} -> {:ok, %{publication: publication}}
      {:error, changeset} -> Helpers.GraphQLErrors.something_went_wrong()
    end
  end

  def resolve_send_publication_membership_invitation(_, _) do

  end

  def resolve_accept_publication_membership_invitation(_, _) do

  end

  def resolve_reject_publication_membership_invitation(_, _) do

  end
end
