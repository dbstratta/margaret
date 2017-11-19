defmodule MargaretWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  import_types MargaretWeb.Schema.AccountTypes
  import_types MargaretWeb.Schema.StoryTypes

  alias MargaretWeb.Resolvers

  node interface do
    resolve_type fn
      _, _ ->
        nil
    end
  end

  @desc "The root query type."
  query do
    @desc "Lookup a node by its global id."
    node field do
      resolve fn
        %{type: :user, id: id}, resolution ->
          Resolvers.Accounts.resolve_user_by_id(%{user_id: id}, resolution)
      end
    end

    @desc "Get the authenticated user."
    field :me, non_null(:user) do
      resolve &Resolvers.Accounts.resolve_me/2
    end

    @desc "Lookup a user by its username."
    field :user, :user do
      arg :username, non_null(:string)
      resolve &Resolvers.Accounts.resolve_user/2
    end

    @desc "Lookup a story by its author and title."
    field :story, :story do
      arg :author, non_null(:string)
      arg :title, non_null(:string)
      resolve &Resolvers.Stories.resolve_story/2
    end
  end

  mutation do
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
