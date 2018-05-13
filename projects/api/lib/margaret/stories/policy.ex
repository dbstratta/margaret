defmodule Margaret.Stories.Policy do
  @moduledoc """
  Policy module for Stories.
  """

  @behaviour Bodyguard.Policy

  @impl Bodyguard.Policy
  def authorize(_action, _, _) do
    :ok
  end
end
