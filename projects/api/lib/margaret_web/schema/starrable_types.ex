defmodule MargaretWeb.Schema.StarrableTypes do
  @moduledoc """
  The Starrable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  interface :starrable do
    field :id, non_null(:id)
    resolve_type fn
      _, _ ->
        nil
    end

    @desc "The stargazers of the starrable."
    field :stargazers, :user_connection
    resolve_type fn
      _, _ ->
        nil
    end
  end
end
