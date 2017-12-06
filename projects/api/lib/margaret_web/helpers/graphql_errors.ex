defmodule MargaretWeb.Helpers.GraphQLErrors do
  def unauthorized do
    {:error, "Unauthorized"}
  end
end
