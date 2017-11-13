defmodule MargaretWeb.Router do
  use MargaretWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :graphql do
    plug :accepts, ["json"]
  end

  scope "/", MargaretWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/graphql", MargaretWeb do
    pipe_through :graphql

    get "/graphql", PageController, :index
  end
end
