defmodule MargaretWeb.Schema.NotificationTypes do
  @moduledoc """
  The Notification GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  connection node_type: :notification

  node object :notification do
    field :read, :boolean
  end

  object :notification_queries do
    connection field :notifications, node_type: :notification do
      resolve &Resolvers.Notifications.resolve_notifications/2
    end
  end

  object :notification_mutations do
    @desc "Creates a new user."
    payload field :read_notification do
      input do
        field :notification_id, non_null(:id)
      end

      output do
        field :user, non_null(:user)
      end
    end
  end
end
