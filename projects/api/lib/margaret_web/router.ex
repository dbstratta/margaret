defmodule MargaretWeb.Router do
  use MargaretWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :api

    forward "/graphql", Absinthe.Plug,
      schema: MargaretWeb.Schema

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: MargaretWeb.Schema
  end
end
