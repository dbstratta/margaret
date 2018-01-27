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
    value(:updated)
    value(:deleted)
    value(:followed)
    value(:starred)
    value(:commented)
  end

  connection node_type: :notification do
    @desc "The total count of notifications."
    field(:total_count, non_null(:integer))

    # We need to call the `edge` macro in custom connection types.
    @desc "An edge in a connection."
    edge do
    end
  end

  @desc """
  A notification is an event.
  """
  node object(:notification) do
    field :object, :notification_object do
      resolve(&Resolvers.Notifications.resolve_object/3)
    end

    field(:action, non_null(:notification_action))

    field :actor, :user do
      resolve(&Resolvers.Notifications.resolve_actor/3)
    end

    field :read_at, :naive_datetime do
      resolve(&Resolvers.Notifications.resolve_read_at/3)
    end

    field(:inserted_at, non_null(:naive_datetime))
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
