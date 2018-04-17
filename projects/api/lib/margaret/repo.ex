defmodule Margaret.Repo do
  use Ecto.Repo, otp_app: :margaret

  @doc """
  """
  @spec count(Ecto.Queryable.t(), Keyword.t()) :: non_neg_integer()
  def count(query, opts \\ []) do
    aggregate(query, :count, :id, opts)
  end
end
