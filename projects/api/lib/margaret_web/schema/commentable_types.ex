defmodule MargaretWeb.Schema.CommentableTypes do
  @moduledoc """
  The Commentable GraphQL interface.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  interface :commentable do
    field :id, non_null(:id)

    @desc "The stargazers of the starrable."
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
      end

      output do
        field :commentable, non_null(:commentable)
      end

      middleware Absinthe.Relay.Node.ParseIDs, commentable_id: [:story, :comment]
      resolve &Resolvers.Commentable.resolve_comment/2
    end
  end
end
