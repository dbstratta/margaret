defmodule MargaretWeb.Schema do
  @moduledoc """
  The GraphQL schema.
  """

  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias MargaretWeb.Schema.{
    NodeTypes,
    AccountTypes,
    StoryTypes,
    PublicationTypes,
    PublicationMembershipInvitationTypes,
    NotificationTypes,
    StarrableTypes,
  }

  import_types Absinthe.Type.Custom

  import_types NodeTypes
  import_types AccountTypes
  import_types StoryTypes
  import_types PublicationTypes
  import_types PublicationMembershipInvitationTypes
  import_types NotificationTypes
  import_types StarrableTypes

  @desc "The root query type."
  query do
    import_fields :node_queries
    import_fields :account_queries
    import_fields :story_queries
    import_fields :publication_queries
    import_fields :notification_queries
  end

  @desc "The root mutation type."
  mutation do
    import_fields :account_mutations
    import_fields :story_mutations
    import_fields :starrable_mutations
    import_fields :publication_mutations
    import_fields :publication_membership_invitation_mutations
  end
end
