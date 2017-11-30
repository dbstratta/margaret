# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :margaret,
  ecto_repos: [Margaret.Repo]

# Configures the endpoint
config :margaret, MargaretWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5FHUpeKAme+nsDLYD9OvooYr6AKyzQppZegTzAG1xI8m1Ljko+11ztUdOR3IFC0u",
  render_errors: [view: MargaretWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Margaret.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []},
    google: {Ueberauth.Strategy.Google, []},
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("API__GITHUB_CLIENT_ID"),
  client_secret: System.get_env("API__GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("API__GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("API__GOOGLE_CLIENT_SECRET")

# Configures Guardian
config :guardian, MargaretWeb.Guardian,
  issuer: "Margaret",
  secret_key: "Cs+SatzTr/4GlMDYRn+lHQCu+iP7b0hIhr71xDT62J3G+gDb5wlma/UMuxJWOdea"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
