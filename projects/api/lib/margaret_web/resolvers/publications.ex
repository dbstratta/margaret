defmodule MargaretWeb.Resolvers.Publications do
  @moduledoc """
  The Publication GraphQL resolvers.
  """

  alias Margaret.Publications

  def resolve_publication(%{name: name}, _) do
    {:ok, Publications.get_publication_by_name(name)}
  end

  def resolve_members(_, _, _) do

  end

  def resolve_send_publication_membership_invitation(_, _) do

  end

  def resolve_accept_publication_membership_invitation(_, _) do

  end

  def resolve_reject_publication_membership_invitation(_, _) do

  end
end
