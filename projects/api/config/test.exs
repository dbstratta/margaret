use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :margaret, MargaretWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :margaret, MargaretWeb.Mailer, adapter: Swoosh.Adapters.Test

# Configure your database
config :margaret, Margaret.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "margaret_test",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox
