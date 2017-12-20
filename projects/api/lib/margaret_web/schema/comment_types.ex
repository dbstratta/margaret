defmodule MargaretWeb.Schema.CommentTypes do
  @moduledoc """
  The Comment GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  connection node_type: :comment

  node object :comment do
    @desc "The body of the comment."
    field :body, non_null(:string)

    @desc "The author of the comment."
    field :author, non_null(:user) do
      resolve &Resolvers.Comments.resolve_user/3
    end

    @desc "Identifies the date and time when the comment was created."
    field :created_at, non_null(:datetime)

    @desc "The stargazers of the comment."
    connection field :stargazers, node_type: :user do
      resolve &Resolvers.Starrable.resolve_stargazers/3
    end

    @desc "The star count of the comment."
    field :star_count, non_null(:integer) do
      resolve &Resolvers.Comments.resolve_star_count/3
    end

    @desc "The comments of the comments."
    connection field :comments, node_type: :comment do
      resolve &Resolvers.Comments.resolve_comments/3
    end

    field :viewer_can_star, non_null(:boolean) do
      resolve &Resolvers.Comments.resolve_viewer_can_star/3
    end

    @desc "Check if the current viewer can comment this object."
    field :viewer_can_comment, non_null(:boolean) do
      resolve &Resolvers.Comments.resolve_viewer_can_comment/3
    end

    interfaces [:starrable]
  end
end
