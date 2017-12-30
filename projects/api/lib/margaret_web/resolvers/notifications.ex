defmodule MargaretWeb.Resolvers.Notifications do
  @moduledoc """
  The Notification GraphQL resolvers.
  """

  alias MargaretWeb.Helpers

  def resolve_read_notification(_, _) do
    Helpers.GraphQLErrors.not_implemented()
  end
end
