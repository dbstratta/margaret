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
      resolve &Resolvers.Comments.resolve_author/3
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

    field :story, non_null(:story) do
      resolve &Resolvers.Comments.resolve_story/3
    end

    field :parent, :comment do
      resolve &Resolvers.Comments.resolve_parent/3
    end

    @desc "The comments of the comments."
    connection field :comments, node_type: :comment do
      resolve &Resolvers.Comments.resolve_comments/3
    end

    field :viewer_can_star, non_null(:boolean) do
      resolve &Resolvers.Comments.resolve_viewer_can_star/3
    end

    field :viewer_has_starred, non_null(:boolean) do
      resolve &Resolvers.Comments.resolve_viewer_has_starred/3
    end

    @desc "Check if the current viewer can comment this comment."
    field :viewer_can_comment, non_null(:boolean) do
      resolve &Resolvers.Comments.resolve_viewer_can_comment/3
    end

    @desc "Check if the viewer can update this comment."
    field :viewer_can_update, non_null(:boolean) do
      resolve &Resolvers.Comments.resolve_viewer_can_update/3
    end

    interfaces [:starrable, :commentable, :updatable]
  end

  object :comment_mutations do
    @desc "Updates a comment."
    payload field :update_comment do
      input do
        field :comment_id, non_null(:id)
        field :body, :string
      end

      output do
        field :comment, non_null(:comment)
      end

      middleware Absinthe.Relay.Node.ParseIDs, comment_id: :comment
      resolve &Resolvers.Comments.resolve_update_comment/2
    end

    @desc "Deletes a comment."
    payload field :delete_comment do
      input do
        field :comment_id, non_null(:id)
      end

      output do
        field :comment, non_null(:comment)
      end

      middleware Absinthe.Relay.Node.ParseIDs, comment_id: :comment
      resolve &Resolvers.Comments.resolve_delete_comment/2
    end
  end
end
