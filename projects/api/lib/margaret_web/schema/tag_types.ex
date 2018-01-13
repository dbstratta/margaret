defmodule MargaretWeb.Schema.TagTypes do
  @moduledoc """
  The Tag GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  @desc """
  A story tag.
  """
  node object :tag do
    @desc "The title of the tag."
    field :title, non_null(:string)
  end
end
