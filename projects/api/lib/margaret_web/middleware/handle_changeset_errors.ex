defmodule MargaretWeb.Middleware.HandleChangesetErrors do
  @moduledoc """
  Absinthe middleware to format changeset errors.

  Checks for errors in the resolution,
  if they are changesets, formats them.
  """

  alias MargaretWeb.Helpers

  @behaviour Absinthe.Middleware

  @doc false
  @impl true
  def call(%Absinthe.Resolution{errors: errors} = resolution, _) do
    %{resolution | errors: handle_errors(errors)}
  end

  defp handle_errors(errors), do: Enum.flat_map(errors, &handle_error/1)

  defp handle_error(%Ecto.Changeset{} = changeset), do: Helpers.format_changeset(changeset)

  defp handle_error(error), do: [error]
end
