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
    Enum.reduce opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", to_string(value), global: true)
    end
  end
end