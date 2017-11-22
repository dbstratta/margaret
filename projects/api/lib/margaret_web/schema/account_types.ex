defmodule MargaretWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  @desc "A user is an individual's account on Margaret that can make new content."
  node object :user do
    @desc "The username of the user."
    field :username, non_null(:string)

    @desc "The email of the user."
    field :email, non_null(:string)

    @desc "The biography of the user."
    field :bio, :string
    # connection field :stories, node_type: :story do
    #   resolve &Resolvers.Stories.resolve_user_posts/3
    # end
  end

  object :account_queries do
    @desc "Get the authenticated user."
    field :me, :user do
      resolve &Resolvers.Accounts.resolve_me/2
    end

    @desc "Lookup a user by its username."
    field :user, :user do
      arg :username, :string
      arg :id, :id
      resolve &Resolvers.Accounts.resolve_user/2
    end
  end

  object :account_mutations do
    @desc "Creates a new user."
    payload field :create_user do
      input do
        field :username, non_null(:string)
      end
      output do
        field :user, non_null(:user)
      end
    end
  end
end
