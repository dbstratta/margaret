defmodule MargaretWeb.Schema.NotificationTypes do
  @moduledoc """
  The Notification GraphQL types.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias MargaretWeb.Resolvers

  connection(node_type: :notification)

  node object(:notification) do
    field(:read, :boolean)
  end

  object :notification_mutations do
    @desc "Marks a notification as read."
    payload field(:read_notification) do
      input do
        field(:notification_id, non_null(:id))
      end

      output do
        field(:user, non_null(:user))
      end

      middleware(Absinthe.Relay.Node.ParseIDs, notification_id: :notification)
      resolve(&Resolvers.Notifications.resolve_read_notification/2)
    end
  end
end
