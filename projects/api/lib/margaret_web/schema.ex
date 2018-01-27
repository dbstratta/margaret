defmodule MargaretWeb.Schema do
  @moduledoc """
  The GraphQL schema.
  """

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias MargaretWeb.{Schema, Middleware}

  alias Schema.{
    JSONTypes,
    NodeTypes,
    AccountTypes,
    StoryTypes,
    PublicationTypes,
    PublicationInvitationTypes,
    NotificationTypes,
    StarrableTypes,
    BookmarkableTypes,
    FollowableTypes,
    CommentTypes,
    CommentableTypes,
    TagTypes,
    UpdatableTypes,
    DeletableTypes
  }

  alias Middleware.{RequireAuthenticated, RequireActive, HandleChangesetErrors}

  import_types(Absinthe.Type.Custom)

  import_types(JSONTypes)
  import_types(NodeTypes)
  import_types(AccountTypes)
  import_types(StoryTypes)
  import_types(PublicationTypes)
  import_types(PublicationInvitationTypes)
  import_types(NotificationTypes)
  import_types(StarrableTypes)
  import_types(BookmarkableTypes)
  import_types(FollowableTypes)
  import_types(CommentTypes)
  import_types(CommentableTypes)
  import_types(TagTypes)
  import_types(UpdatableTypes)
  import_types(DeletableTypes)

  @desc "The root query type."
  query do
    import_fields(:node_queries)
    import_fields(:account_queries)
    import_fields(:story_queries)
    import_fields(:publication_queries)
  end

  @desc "The root mutation type."
  mutation do
    import_fields(:account_mutations)
    import_fields(:story_mutations)
    import_fields(:starrable_mutations)
    import_fields(:bookmarkable_mutations)
    import_fields(:followable_mutations)
    import_fields(:publication_mutations)
    import_fields(:publication_invitation_mutations)
    import_fields(:comment_mutations)
    import_fields(:commentable_mutations)
  end

  # TODO: See why subscriptions don't work.
  # subscription do
  #   import_fields(:starrable_subscriptions)
  # end

  # middleware/3 callback
  def middleware(middleware, _, %{identifier: :mutation}) do
    Enum.concat([
      [RequireAuthenticated, RequireActive],
      middleware,
      [HandleChangesetErrors]
    ])
  end

  def middleware(middleware, _, %{identifier: :query}) do
    middleware
  end

  def middleware(middleware, _, _), do: middleware
end
