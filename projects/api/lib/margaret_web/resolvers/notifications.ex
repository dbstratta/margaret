defmodule MargaretWeb.Resolvers.Notifications do
  @moduledoc """
  The Notification GraphQL resolvers.
  """

  import Ecto.Query
  alias Absinthe.Relay

  alias MargaretWeb.Helpers
  alias Margaret.Repo

  def resolve_read_notification(_, _) do
    Helpers.GraphQLErrors.not_implemented()
  end
end
