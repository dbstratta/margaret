defmodule MargaretWeb.Schema.NotificationTypes do
  @moduledoc """
  The Notification GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  @desc """
  A notification object.
  """
  union :notification_object do
    types([:story, :user])

    resolve_type(&Resolvers.Nodes.resolve_type/2)
  end

  enum :notification_action do
    value(:added)
  end

  connection(node_type: :notification)

  node object(:notification) do
    field(:object, :notification_object)
    field(:action, non_null(:notification_action))
    field(:actor, :user)
    field(:read, :boolean)
  end

  object :notification_mutations do
    @desc "Marks a notification as read."
    payload field(:read_notification) do
      input do
        field(:notification_id, non_null(:id))
      end

      output do
        field(:notification, non_null(:notification))
      end

      middleware(Absinthe.Relay.Node.ParseIDs, notification_id: :notification)
      resolve(&Resolvers.Notifications.resolve_read_notification/2)
    end
  end
end
