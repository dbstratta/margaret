defmodule MargaretWeb.Schema.StoryTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  node object :story do
    field :title, non_null(:string)
    field :author, non_null(:string)
  end
end
