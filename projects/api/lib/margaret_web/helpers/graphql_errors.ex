defmodule MargaretWeb.Helpers.GraphQLErrors do
  @moduledoc """
  Helper functions for generating GraphQL errors.
  """

  @doc "Return the `Unauthorized` error."
  @spec unauthorized :: {:error, String.t}
  def unauthorized do
    {:error, "Unauthorized"}
  end
end
