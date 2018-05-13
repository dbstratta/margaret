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
end
