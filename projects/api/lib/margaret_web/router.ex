defmodule MargaretWeb.Router do
  use MargaretWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug :accepts, ["json"]
    plug Guardian.Plug.VerifyCookie
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug MargaretWeb.Context
  end

  scope "/" do
    pipe_through :graphql

    forward "/graphql", Absinthe.Plug,
      schema: MargaretWeb.Schema

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: MargaretWeb.Schema
  end
end
