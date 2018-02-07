defmodule MargaretWeb.Schema.JSONTypes do
  @moduledoc false

  use Absinthe.Schema.Notation

  @desc """
  The JSON type.
  """
  scalar :json, name: "JSON" do
    parse(&parse_json/1)
    serialize(&serialize_json/1)
  end

  defp parse_json(%{value: value}) do
    case Poison.decode(value) do
      {:ok, result} -> {:ok, result}
      _ -> :error
    end
  end

  defp serialize_json(value) do
    Poison.encode!(value)
  end
end
