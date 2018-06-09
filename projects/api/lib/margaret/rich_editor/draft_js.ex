defmodule Margaret.RichEditor.DraftJS do
  @behaviour Margaret.RichEditor

  @impl true
  def title(%{"blocks" => [%{"text" => title} | _]}) do
    title
  end

  @impl true
  def summary(%{"blocks" => blocks}) do
    case blocks do
      [_, %{"text" => summary} | _] -> summary
      _ -> ""
    end
  end

  @impl true
  def word_count(%{"blocks" => blocks}) do
    blocks
    |> Enum.map_join(" ", &Map.get(&1, "text"))
    |> String.split()
    |> length()
  end
end
