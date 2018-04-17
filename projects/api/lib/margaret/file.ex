defmodule Margaret.File do
  @moduledoc """

  """

  @doc """
  """
  defmacro __using__(_types) do
    quote do
      use Arc.Definition
      use Arc.Ecto.Definition

      def __storage, do: Arc.Storage.Local
    end
  end
end
