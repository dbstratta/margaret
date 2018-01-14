defmodule MargaretWeb.Schema.CommentableTypes do
  @moduledoc """
  The Commentable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  @commentable_implementations [
    :story,
    :comment,
  ]

  interface :commentable do
    field :id, non_null(:id)

    @desc "The comments of the commentable."
    field :comments, :comment_connection

    @desc "Check if the current viewer can comment this object."
    field :viewer_can_comment, non_null(:boolean)

    resolve_type &Resolvers.Nodes.resolve_type/2
  end

  object :commentable_mutations do
    @desc "Comments a commentable."
    payload field :comment do
      input do
        field :commentable_id, non_null(:id)
        field :content, non_null(:json)
      end

      output do
        field :comment, non_null(:comment)
      end

      middleware Absinthe.Relay.Node.ParseIDs, commentable_id: @commentable_implementations
      resolve &Resolvers.Commentable.resolve_comment/2
    end
  end
end
