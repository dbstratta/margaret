defmodule MargaretWeb.Router do
  use MargaretWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug Guardian.Plug.VerifyHeader
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
      interface: :playground
  end
end
