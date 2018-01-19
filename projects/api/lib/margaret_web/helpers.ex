defmodule MargaretWeb.Helpers do
  @moduledoc """
  Helper functions.
  """

  @doc """
  Formats the errors from a changeset.
  """
  def format_changeset(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(&format_changeset_error/1)
    |> Enum.map(fn {key, value} -> "#{key} #{value}" end)
  end

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
  @spec put_total_count(any, non_neg_integer | nil) :: any
  def put_total_count(connection, nil), do: connection
  def put_total_count(connection, total_count), do: Map.put(connection, :total_count, total_count)

  @doc """
  """
  def transform_edges(connection) do
    Map.update!(connection, :edges, &Enum.map(&1, fn edge -> put_edge_fields(edge) end))
  end

  defp put_edge_fields(%{node: {node, fields}} = edge) do
    edge
    |> Map.merge(fields)
    |> Map.put(:node, node)
  end

  defp put_edge_fields(edge), do: edge

  @doc """
  """
  def transform_connection(tuple_or_connection, opts \\ [])

  def transform_connection({:ok, connection}, opts), do: transform_connection(connection, opts)
  def transform_connection({:error, error}, _), do: {:error, error}

  def transform_connection(connection, opts) do
    total_count = Keyword.get(opts, :total_count)

    connection =
      connection
      |> put_total_count(total_count)
      |> transform_edges()

    {:ok, connection}
  end
end
