defmodule MargaretWeb.Schema.AccountTypes do
  @moduledoc """
  The Account GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  connection node_type: :user

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
    The follower connection of the user.
    """
    connection field :followers, node_type: :user do
      resolve &Resolvers.Accounts.resolve_followers/3
    end

    connection field :followees, node_type: :user do
      resolve &Resolvers.Accounts.resolve_followees/3
    end

    connection field :starred_stories, node_type: :story do
      resolve &Resolvers.Accounts.resolve_starred_stories/3
    end

    field :publication, :publication do
      arg :name, non_null(:string)

      resolve &Resolvers.Accounts.resolve_publication/3
    end

    connection field :publications, node_type: :publication do
      resolve &Resolvers.Accounts.resolve_publications/3
    end

    @desc """
    The notification connection of the user.
    """
    connection field :notifications, node_type: :notification do
      resolve &Resolvers.Accounts.resolve_notifications/3
    end

    field :is_viewer, :boolean do
      resolve &Resolvers.Accounts.resolve_is_viewer/3
    end

    field :viewer_can_follow, non_null(:boolean) do
      resolve &Resolvers.Accounts.resolve_viewer_can_follow/3
    end

    field :viewer_has_followed, non_null(:boolean) do
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
    payload field :update_user do
      input do
        field :username, :string
        field :email, :string
      end

      output do
        field :user, non_null(:user)
      end

      resolve &Resolvers.Accounts.resolve_update_user/2
    end
  end
end
