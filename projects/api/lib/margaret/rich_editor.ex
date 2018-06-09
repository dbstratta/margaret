defmodule Margaret.RichEditor do
  @moduledoc """
  Behaviour module that defines utility functions
  for working with the exported data of
  rich text editors (e.g. DraftJS).
  """

  @doc """
  Returns the title of a rich text editor exported data.

  ## Examples

      iex> title(draft_js_data)
      "Title"

  """
  @callback title(any()) :: String.t()

  @callback summary(any()) :: String.t()

  @callback word_count(any()) :: non_neg_integer()
end
