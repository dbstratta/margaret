defmodule MargaretWeb.Schema.AccountTypes do
  @moduledoc """
  The Account GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.{Resolvers, Middleware}

  @desc """
  The connection type for User.
  """
  connection node_type: :user do
    @desc "The total count of users."
    field :total_count, non_null(:integer)

    # We need to call the `edge` macro in custom connection types.
    @desc "An edge in a connection."
    edge do end
  end

  @desc """
  The connection type for Followee.
  """
  connection :followee, node_type: :followable do
    @desc "The total count of followees."
    field :total_count, non_null(:integer)

    @desc "An edge in a connection."
    edge do
      field :followed_at, non_null(:naive_datetime)
    end
  end

  @desc """
  The connection type for Follower.
  """
  connection :follower, node_type: :user do
    @desc "The total count of followers."
    field :total_count, non_null(:integer)

    @desc "An edge in a connection."
    edge do
      field :followed_at, non_null(:naive_datetime)
    end
  end

  @desc """
  A user is an individual's account on Margaret that can make new content.
  """
  node object :user do
    @desc """
    The username of the user.
    """
    field :username, non_null(:string)

    @desc """
    The email of the user.
    """
    field :email, non_null(:string)

    @desc """
    The biography of the user.
    """
    field :bio, :string

    @desc """
    The stories of the user.
    """
    connection field :stories, node_type: :story do
      resolve &Resolvers.Accounts.resolve_stories/3
    end

    @desc """
    The follower of the user.
    """
    connection field :followers, node_type: :user, connection: :follower do
      resolve &Resolvers.Accounts.resolve_followers/3
    end

    @desc """
    The followees of the user.
    """
    connection field :followees, node_type: :followable, connection: :followee do
      resolve &Resolvers.Accounts.resolve_followees/3
    end

    @desc """
    The starrables that the user starred.
    """
    connection field :starred, node_type: :starrable, connection: :starred do
      resolve &Resolvers.Accounts.resolve_starred/3
    end

    @desc """
    The bookmarkables that the user bookmarked.

    Bookmarks are only visible to the user who did them.
    """
    connection field :bookmarked, node_type: :bookmarkable, connection: :bookmarked do
      resolve &Resolvers.Accounts.resolve_bookmarked/3
    end

    @desc """
    Find a publication the user is member of.
    """
    field :publication, :publication do
      @desc "The name of the publication"
      arg :name, non_null(:string)

      resolve &Resolvers.Accounts.resolve_publication/3
    end

    @desc """
    The publications the user is member of.
    """
    connection field :publications, node_type: :publication, connection: :user_publication do
      resolve &Resolvers.Accounts.resolve_publications/3
    end

    @desc """
    The notification connection of the user.
    """
    connection field :notifications, node_type: :notification do
      middleware Middleware.RequireAuthenticated, resolve: nil
      resolve &Resolvers.Accounts.resolve_notifications/3
    end

    @desc """
    Whether or not this user is a Margaret employee.
    """
    field :is_employee, non_null(:boolean)

    @desc """
    Whether or not this user is a site administrator.
    """
    field :is_admin, non_null(:boolean)

    @desc """
    Whether or not this user is the viewing user.
    """
    field :is_viewer, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Accounts.resolve_is_viewer/3
    end

    field :viewer_can_follow, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Accounts.resolve_viewer_can_follow/3
    end

    field :viewer_has_followed, non_null(:boolean) do
      middleware Middleware.RequireAuthenticated, resolve: false
      resolve &Resolvers.Accounts.resolve_viewer_has_followed/3
    end

    @desc """
    Identifies the date and time when the user was created.
    """
    field :inserted_at, non_null(:naive_datetime)

    @desc """
    Identifies the date and time when the user was last updated.
    """
    field :updated_at, non_null(:naive_datetime)

    interfaces [:followable]
  end

  object :account_queries do
    @desc """
    Get the authenticated user.
    """
    field :viewer, :user do
      middleware Middleware.RequireAuthenticated, resolve: nil
      resolve &Resolvers.Accounts.resolve_viewer/2
    end

    @desc """
    Lookup a user by its username.
    """
    field :user, :user do
      @desc "The username of the user."
      arg :username, non_null(:string)

      resolve &Resolvers.Accounts.resolve_user/2
    end

    @desc """
    Get the user list.
    """
    connection field :users, node_type: :user do
      resolve &Resolvers.Accounts.resolve_users/2
    end
  end

  object :account_mutations do
    @desc """
    Creates a new user.
    """
    payload field :create_user do
      input do
        field :username, non_null(:string)
      end

      output do
        field :user, non_null(:user)
      end
    end

    @desc """
    Updates the currently logged in user.
    """
    payload field :update_viewer do
      input do
        field :username, :string
        field :email, :string
      end

      output do
        field :viewer, non_null(:user)
      end

      middleware Absinthe.Relay.Node.ParseIDs, user_id: :user
      resolve &Resolvers.Accounts.resolve_update_viewer/2
    end

    @desc """
    Deactivates the currently logged in user.
    """
    payload field :deactivate_viewer do
      output do
        field :viewer, non_null(:user)
      end

      resolve &Resolvers.Accounts.resolve_deactivate_viewer/2
    end

    @desc """
    Deactivates the currently logged in user and marks
    it for deletion.
    
    After a fixed period of time, if not activated, the account
    will be permanently deleted, along with all its content (stories, comments, etc.).
    """
    payload field :mark_viewer_for_deletion do
      output do
        field :viewer, non_null(:user)
      end

      resolve &Resolvers.Accounts.resolve_mark_viewer_for_deletion/2
    end
  end
end
