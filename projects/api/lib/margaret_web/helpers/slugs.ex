defmodule MargaretWeb.Helpers.Slugs do
  @moduledoc """
  Helper functions for working with slugs.
  """

  @typedoc "The slug type"
  @type t :: String.t

  @doc """
  Generates a unique slug from a string.

  Slugs have a hash appended at the end. The result should be unique.
  """
  @spec new(String.t) :: String.t
  def new(string) when is_binary(string) do
    string
    |> String.trim()
    |> String.replace(~r/\s/, "-")
    # Replace any non alphanumeric, `-`, or `_` for an empty string.
    |> String.replace(~r/[^a-zA-Z0-9-_]/, "")
    |> String.downcase()
    |> Kernel.<>("-#{generate_hash()}")
  end

  @spec generate_hash :: String.t
  defp generate_hash() do
    "3000"
  end
end
