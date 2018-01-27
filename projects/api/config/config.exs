# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :margaret, ecto_repos: [Margaret.Repo]

# Configures the endpoint
config :margaret, MargaretWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5FHUpeKAme+nsDLYD9OvooYr6AKyzQppZegTzAG1xI8m1Ljko+11ztUdOR3IFC0u",
  render_errors: [view: MargaretWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Margaret.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures CORSPlug
config :cors_plug, methods: ["GET", "POST"]

# Configures Ueberauth
config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []},
    google: {Ueberauth.Strategy.Google, []},
    facebook: {Ueberauth.Strategy.Facebook, []}
  ]

# Configures Github's Oauth2
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

# Configures Google's Oauth2
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: System.get_env("GOOGLE_CLIENT_ID"),
  client_secret: System.get_env("GOOGLE_CLIENT_SECRET")

# Configures Facebook's Oauth2
config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
  client_id: System.get_env("FACEBOOK_CLIENT_ID"),
  client_secret: System.get_env("FACEBOOK_CLIENT_SECRET")

# Configures Guardian
config :margaret, MargaretWeb.Guardian,
  issuer: "Margaret",
  secret_key: "Cs+SatzTr/4GlMDYRn+lHQCu+iP7b0hIhr71xDT62J3G+gDb5wlma/UMuxJWOdea"

# Configures Swoosh
config :margaret, Margaret.Mailer, adapter: Swoosh.Adapters.Local

# Configures Sentry
config :sentry,
  dsn: System.get_env("API__SENRTY_DSN"),
  included_environments: [:prod],
  environment_name: Mix.env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!()

# Configures Exq
config :exq,
  name: Exq,
  host: "redis",
  port: 6379,
  namespace: "exq",
  concurrency: 500,
  queues: ["user_deletion", "story_publication"],
  scheduler_enable: true

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
