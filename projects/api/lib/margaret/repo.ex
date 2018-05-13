defmodule Margaret.Repo do
  use Ecto.Repo, otp_app: :margaret
  import Ecto.Query, only: [select: 2, limit: 2]

  @doc """
  Returns the count of rows matching the query.

  ## Examples

      iex> from(u in User)
      ...> |> count()
      42

  """
  @spec count(Ecto.Queryable.t(), Keyword.t()) :: non_neg_integer()
  def count(query, opts \\ []) do
    {field, opts} = Keyword.pop(opts, :field, :id)

    aggregate(query, :count, field, opts)
  end

  def avg(query, field, opts \\ []), do: aggregate(query, :avg, field, opts)

  def sum(query, field, opts \\ []), do: aggregate(query, :sum, field, opts)

  def min(query, field, opts \\ []), do: aggregate(query, :min, field, opts)

  def max(query, field, opts \\ []), do: aggregate(query, :max, field, opts)

  @doc """
  Returns `true` if there's something in the repository
  that matches the query.

  ## Examples

      iex> from(u in User)
      ...> |> exists?()
      true

  """
  @spec exists?(Ecto.Queryable.t()) :: non_neg_integer()
  def exists?(query) do
    query
    # It doesn't matter the value in the select call,
    # but we need something to match when we get the result from Ecto.
    |> select(true)
    |> limit(1)
    |> one()
    |> case do
      true -> true
      nil -> false
    end
  end
end
