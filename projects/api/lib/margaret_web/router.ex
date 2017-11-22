defmodule MargaretWeb.Router do
  use MargaretWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug MargaretWeb.Plugs.PreventCSRF
    plug Guardian.Plug.VerifyCookie
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug MargaretWeb.Context
  end

  scope "/oauth" do
    pipe_through :api
  end

  scope "/" do
    pipe_through :graphql

    forward "/graphql", Absinthe.Plug,
      schema: MargaretWeb.Schema

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: MargaretWeb.Schema,
      interface: :playground,
      default_headers: {__MODULE__, :graphiql_headers}
  end

  def graphiql_headers do
    %{"X-Requested-With" => "XMLHttpRequest"}
  end
end
