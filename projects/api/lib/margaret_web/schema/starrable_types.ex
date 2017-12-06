defmodule MargaretWeb.Schema.StarrableTypes do
  @moduledoc """
  The Starrable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  interface :starrable do
    field :id, non_null(:id)

    @desc "The stargazers of the starrable."
    field :stargazers, :user_connection

    resolve_type fn
      _, _ ->
        nil
    end
  end

  object :starrable_mutations do
    @desc "Stars a starrable."
    payload field :star do
      input do
        field :starrable_id, non_null(:id)
      end

      output do
        field :starrable, non_null(:starrable)
      end
    end

    @desc "Unstars a starrable."
    payload field :unstar do
      input do
        field :starrable_id, non_null(:id)
      end

      output do
        field :starrable, non_null(:starrable)
      end
    end
  end
end
