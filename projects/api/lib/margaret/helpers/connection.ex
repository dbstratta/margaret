defmodule Margaret.Helpers.Connection do
  @moduledoc """
  Helper functions for working with pagination connections.

  See https://facebook.github.io/relay/graphql/connections.htm
  for more information.
  """

  alias Absinthe.Relay

  alias Margaret.{Repo, Helpers}

  @doc """
  Returns a pagination connection from a query.

  ## Options

    * `:total_count` - when true, inserts the `total_count`
      key into the connection.
      It gets the count from the query provided.
      Defaults to `true`.

  ## Examples

      iex> from_query(query, args, total_count: false)
      {:ok, connection}

  """
  @spec from_query(Ecto.Queryable.t(), map(), Keyword.t()) :: {:ok, map()} | {:error, any()}
  def from_query(query, args, opts \\ []) do
    total_count =
      if Keyword.get(opts, :total_count, true) do
        Repo.count(query)
      else
        nil
      end

    case Relay.Connection.from_query(query, &Repo.all/1, args) do
      {:ok, connection} ->
        connection
        |> put_total_count(total_count)
        |> transform_edges()
        |> Helpers.ok()

      error ->
        error
    end
  end

  # Puts `total_count` in the connection.
  # If `total_count` is `nil`, doesn't do anything.
  @spec put_total_count(any, non_neg_integer() | nil) :: any()
  defp put_total_count(connection, total_count) when not is_nil(total_count),
    do: Map.put(connection, :total_count, total_count)

  defp put_total_count(connection, nil), do: connection

  @spec transform_edges(map()) :: map()
  defp transform_edges(connection) do
    Map.update!(connection, :edges, &Enum.map(&1, fn edge -> put_edge_fields(edge) end))
  end

  @spec put_edge_fields(map()) :: map()
  defp put_edge_fields(%{node: {nodes, fields}} = edge) when is_list(nodes) do
    node = Enum.find(nodes, &(not is_nil(&1)))

    do_put_edge_fields(edge, node, fields)
  end

  defp put_edge_fields(%{node: {node, fields}} = edge), do: do_put_edge_fields(edge, node, fields)

  defp put_edge_fields(edge), do: edge

  @spec do_put_edge_fields(map(), map(), map()) :: map()
  defp do_put_edge_fields(edge, node, fields) do
    edge
    |> Map.merge(fields)
    |> Map.put(:node, node)
  end
end
