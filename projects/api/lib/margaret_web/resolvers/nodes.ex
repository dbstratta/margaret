defmodule MargaretWeb.Resolvers.Nodes do
  alias MargaretWeb.Resolvers

  def resolve_node(%{type: :user, id: user_id}, _) do
    Resolvers.Accounts.resolve_user_by_id(user_id)
  end
end
