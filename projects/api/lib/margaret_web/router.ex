defmodule MargaretWeb.Router do
  use MargaretWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MargaretWeb do
    pipe_through :api
  end
end
