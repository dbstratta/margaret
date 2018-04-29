defmodule MargaretWeb.Context do
  @moduledoc """
  Plug that builds the GraphQL context before every request.

  The context is a map we can access from the GraphQL resolvers,
  and it's useful to store in it data about the request, for example
  the user that made it.
  """

  @behaviour Plug

  alias Margaret.Accounts.User

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _) do
    context =
      conn
      |> Guardian.Plug.current_resource()
      |> case do
        %User{} = viewer -> %{viewer: viewer}
        nil -> %{}
      end

    Absinthe.Plug.put_options(conn, context: context)
  end
end
