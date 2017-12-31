defmodule MargaretWeb.Middleware.HandleChangesetErrors do
  @moduledoc """
  Absinthe middleware to format changeset errors.

  Checks for errors in the resolution,
  if they are changesets, formats them.
  """

  @behaviour Absinthe.Middleware

  @doc false
  @impl true
  def call(%Absinthe.Resolution{errors: []} = resolution, _), do: resolution

  def call(%Absinthe.Resolution{errors: errors} = resolution, _) do
    %{resolution | errors: handle_errors(errors)}
  end

  defp handle_errors(errors), do: Enum.flat_map(errors, &handle_error/1)

  defp handle_error(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {err, _opts} -> err end)
    |> Enum.map(fn {key, value} -> "#{key}: #{value}" end)
  end

  defp handle_error(error), do: [error]
end