defmodule MargaretWeb.Schema.StoryTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation

  node object :story do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :author, non_null(:string)
  end
end
