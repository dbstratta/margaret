defmodule MargaretWeb.Schema.AccountTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation

  alias MargaretWeb.Resolvers

  @desc "A user is an individual's account on Margaret that can make new content."
  node object :user do
    field :id, non_null(:id)
    field :username, non_null(:string)
    field :email, non_null(:string)
    field :bio, :string
    # connection field :stories, node_type: :story do
    # end
  end
end
