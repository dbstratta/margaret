defmodule MargaretWeb.Resolvers.Nodes do
  alias Margaret.Accounts

  def resolve_node(%{type: :user, id: user_id}, _) do
    Accounts.get_user(user_id)
  end
end
