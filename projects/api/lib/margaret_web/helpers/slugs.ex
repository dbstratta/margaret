defmodule MargaretWeb.Helpers.Slugs do
  @moduledoc """
  Helper functions for working with slugs.
  """

  @typedoc "The slug type"
  @type t :: String.t

  @doc """
  """
  @spec new(String.t) :: String.t
  def new(title) do
    title
    |> String.replace(~r/\s/, "-")
    |> Kernel.<>("-")
    |> Kernel.<>("3000")
  end
end
