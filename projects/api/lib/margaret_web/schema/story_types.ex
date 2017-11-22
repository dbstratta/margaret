defmodule MargaretWeb.Schema.StoryTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  node object :story do
    field :title, non_null(:string)
    field :author, non_null(:string)
  end

  object :story_queries do
    @desc "Lookup a story by its author and title."
    field :story, :story do
      arg :author, non_null(:string)
      arg :title, non_null(:string)
      resolve &Resolvers.Stories.resolve_story/2
    end
  end
end
