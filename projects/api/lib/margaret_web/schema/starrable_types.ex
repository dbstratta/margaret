defmodule MargaretWeb.Schema.StarrableTypes do
  @moduledoc """
  The Starrable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  @starrable_implementations [
    :story,
    :comment
  ]

  @desc """
  Things that can be starrable.
  """
  interface :starrable do
    field(:id, non_null(:id))

    @desc """
    The stargazers of the starrable.
    """
    connection field(:stargazers, node_type: :user, connection: :stargazer) do
    end

    @desc """
    Indicates whether the viewer can star this starrable.
    """
    field(:viewer_can_star, non_null(:boolean))

    @desc """
    Returns a boolean indicating whether the viewing user has starred this starrable.
    """
    field(:viewer_has_starred, non_null(:boolean))

    resolve_type(&Resolvers.Nodes.resolve_type/2)
  end

  @desc """
  The connection type for Starred.
  """
  connection :starred, node_type: :starrable do
    @desc "The total count of starrables starred."
    field(:total_count, non_null(:integer))

    @desc "An edge in a connection."
    edge do
      field(:starred_at, non_null(:naive_datetime))
    end
  end

  @desc """
  The connection type for Stargazer.
  """
  connection :stargazer, node_type: :user do
    @desc "The total count of stargazers."
    field(:total_count, non_null(:integer))

    @desc "An edge in a connection."
    edge do
      field(:starred_at, non_null(:naive_datetime))
    end
  end

  @desc """
  The connection type for Starrable.
  """
  connection node_type: :starrable do
    @desc "The total count of starrables."
    field(:total_count, non_null(:integer))

    @desc "An edge in a connection."
    edge do
    end
  end

  object :starrable_mutations do
    @desc """
    Stars a starrable.
    """
    payload field(:star) do
      input do
        @desc "The id of the starrable."
        field(:starrable_id, non_null(:id))
      end

      output do
        field(:starrable, non_null(:starrable))
      end

      middleware(Absinthe.Relay.Node.ParseIDs, starrable_id: @starrable_implementations)
      resolve(&Resolvers.Starrable.resolve_star/2)
    end

    @desc """
    Unstars a starrable.
    """
    payload field(:unstar) do
      input do
        @desc "The id of the starrable."
        field(:starrable_id, non_null(:id))
      end

      output do
        field(:starrable, non_null(:starrable))
      end

      middleware(Absinthe.Relay.Node.ParseIDs, starrable_id: @starrable_implementations)
      resolve(&Resolvers.Starrable.resolve_unstar/2)
    end
  end

  object :starrable_subscriptions do
    field :starrable_starred, :starrable do
      arg(:starrable_id, non_null(:id))

      config(fn args, _ ->
        {:ok, topic: args.starrable_id}
      end)

      trigger(
        :star,
        topic: fn %{starrable: starrable} ->
          starrable.id
        end
      )
    end
  end
end
