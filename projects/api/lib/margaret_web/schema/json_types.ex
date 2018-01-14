defmodule MargaretWeb.Schema.JSONTypes do
  use Absinthe.Schema.Notation

  @desc """
  The JSON type.
  """
  scalar :json, name: "JSON" do
    parse &parse_json/1
    serialize &Poison.encode!/1
  end

  defp parse_json(%{value: value}) do
    case Poison.decode(value) do
      {:ok, result} -> {:ok, result}
      _ -> :error
    end
  end
end