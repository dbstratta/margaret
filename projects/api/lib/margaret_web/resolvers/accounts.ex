defmodule MargaretWeb.Resolvers.Accounts do
  alias MargaretWeb.Utils.ErrorMessages

  def resolve_me(_, %{context: %{user: user}} = resolution),
    do: resolve_user(%{id: user.id}, resolution)

  def resolve_me(_, _), do: ErrorMessages.unauthorized()

  def resolve_user(%{username: username}, _) when not is_nil(username) do
    # TODO
  end

  def resolve_user(%{id: user_id}, _) when not is_nil(user_id) do
    # TODO
  end

  def resolve_user(%{id: nil, username: nil}, _), do: {:error, ""}

  def create_user(%{}) do
    # TODO
  end
end
