defmodule MargaretWeb.Schema.CommentTypes do
  @moduledoc """
  The Comment GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.{Resolvers, Middleware}

  @desc """
  The connection type for Comment.
  """
  connection node_type: :comment do
    @desc "The total count of comments."
    field :total_count, non_null(:integer)

    @desc "An edge in a connection."
    edge do end
  end

  @desc """
  The comment object.
  """
  node object :comment do
    @desc """
    The content of the comment.
    """
    field :content, non_null(:json)

    @desc """
    The author of the comment.
    """
    field :author, non_null(:user) do
      resolve &Resolvers.Comments.resolve_author/3
    end

    @desc """
    Identifies the date and time when the comment was created.
    """
    field :created_at, non_null(:datetime)

    @desc """
    The stargazers of the comment.
    """
    connection field :stargazers, node_type: :user, connection: :stargazer do
      resolve &Resolvers.Comments.resolve_stargazers/3
    end

    @desc """
    The story of the comment.
    """
    field :story, non_null(:story) do
      resolve &Resolvers.Comments.resolve_story/3
    end

    @desc """
    The parent comment of the comment.
    """
    field :parent, :comment do
      resolve &Resolvers.Comments.resolve_parent/3
    end

    @desc "The comments of the comments."
    connection field :comments, node_type: :comment do
      resolve &Resolvers.Comments.resolve_comments/3
    end

    @desc """
    Indicates whether the viewer can star this comment.
    """
    field :viewer_can_star, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Comments.resolve_viewer_can_star/3
    end

    @desc """
    Returns a boolean indicating whether the viewing user has starred this comment.
    """
    field :viewer_has_starred, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Comments.resolve_viewer_has_starred/3
    end

    @desc """
    Indicates whether the viewer can bookmark this comment.
    """
    field :viewer_can_bookmark, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Comments.resolve_viewer_can_bookmark/3
    end

    @desc """
    Returns a boolean indicating whether the viewing user has bookmarked this comment.
    """
    field :viewer_has_bookmarked, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Comments.resolve_viewer_has_bookmarked/3
    end

    @desc """
    Indicates whether the viewer can comment on this comment.
    """
    field :viewer_can_comment, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Comments.resolve_viewer_can_comment/3
    end

    @desc """
    Indicates whether the viewer can update this comment.
    """
    field :viewer_can_update, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Comments.resolve_viewer_can_update/3
    end

    @desc """
    Indicates whether the viewer can delete this comment.
    """
    field :viewer_can_delete, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Comments.resolve_viewer_can_delete/3
    end

    interfaces [:starrable, :bookmarkable, :commentable, :updatable, :deletable]
  end

  object :comment_mutations do
    @desc "Updates a comment."
    payload field :update_comment do
      input do
        field :comment_id, non_null(:id)
        field :content, :json
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
