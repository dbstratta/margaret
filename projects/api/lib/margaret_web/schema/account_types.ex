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
end
