defmodule MargaretWeb.Helpers do
  @moduledoc """
  Helper functions.
  """

  @doc """
  Returns an ok tuple with the thing to use in GraphQL resolvers.
  """
  @spec ok(any()) :: Absinthe.Type.Field.ok_result()
  def ok(thing), do: {:ok, thing}

  @doc """
  Formats the errors from a changeset.
  """
  @spec format_changeset(Ecto.Changeset.t()) :: [String.t()]
  def format_changeset(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&format_changeset_error/1)
    |> Enum.map(fn {key, value} -> "#{key} #{value}" end)
  end

  @spec format_changeset_error({String.t(), map()}) :: String.t()
  defp format_changeset_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value), global: true)
    end)
  end

  @doc """
  Puts `total_count` in the connection.

  If `total_count` is `nil`, doesn't do anything.

  ## Examples

    iex> put_total_count(connection, 23)
    connection

    iex> put_total_count(connection, nil)
    connection

  """
  @spec put_total_count(any, non_neg_integer() | nil) :: any()
  def put_total_count(connection, nil), do: connection
  def put_total_count(connection, total_count), do: Map.put(connection, :total_count, total_count)

  @doc """
  """
  @spec transform_edges(map()) :: map()
  def transform_edges(connection) do
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

  @doc """
  """
  @spec transform_connection({:ok, map()} | map(), Keyword.t()) :: {:ok, map()}
  @spec transform_connection({:error, any()}, Keyword.t()) :: {:error, any()}
  def transform_connection(tuple_or_connection, opts \\ [])

  def transform_connection({:ok, connection}, opts), do: transform_connection(connection, opts)
  def transform_connection({:error, error}, _), do: {:error, error}

  def transform_connection(connection, opts) do
    total_count = Keyword.get(opts, :total_count)

    connection
    |> put_total_count(total_count)
    |> transform_edges()
    |> ok()
  end
end
