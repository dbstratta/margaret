defmodule MargaretWeb.Schema.StoryTypes do
  @moduledoc """
  The Story GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  connection node_type: :story

  node object :story do
    @desc "The title of the story."
    field :title, non_null(:string)

    @desc "The body of the story."
    field :body, non_null(:string)

    @desc "The author of the story."
    field :author, non_null(:string)

    @desc "The slug of the story."
    field :slug, non_null(:string)

    @desc "The summary of the story."
    field :summary, :string

    @desc "Identifies the date and time when the object was created."
    field :created_at , non_null(:datetime)

    @desc ""
    connection field :stargazers, node_type: :user do
      resolve fn -> nil end
    end

    interfaces [:starrable]
  end

  object :story_queries do
    @desc "Lookup a story by its slug"
    field :story, :story do
      arg :slug, non_null(:string)

      resolve &Resolvers.Stories.resolve_story/2
    end

    @desc "Lookup stories"
    connection field :stories, node_type: :story do
      resolve &Resolvers.Stories.resolve_stories/2
    end
  end

  object :story_mutations do
    @desc "Creates a story."
    payload field :create_story do
      input do
        field :title, non_null(:string)
        field :body, non_null(:string)
        field :summary, :string
      end

      output do
        field :story, non_null(:story)
      end

      resolve &Resolvers.Stories.resolve_create_story/2
    end

    @desc "Updates a story."
    payload field :update_story do
      input do
        field :title, :string
        field :summary, :string
      end

      output do
        field :story, non_null(:story)
      end
    end

    @desc "Deletes a story."
    payload field :delete_story do
      input do
        field :id, non_null(:id)
      end

      output do
        field :story, non_null(:story)
      end
    end
  end
end
