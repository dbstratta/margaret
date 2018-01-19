defmodule Margaret.Mixfile do
  use Mix.Project

  def project do
    [
      app: :margaret,
      version: "0.0.1",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Margaret.Application, []},
      extra_applications: [:crypto, :logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0.2"},
      {:phoenix_ecto, "~> 3.3.0"},
      {:ecto, "~> 2.2.8", override: true},
      {:ecto_enum, "~> 1.1.0"},
      {:postgrex, "~> 0.13.3"},
      {:gettext, "~> 0.14.0"},
      {:cowboy, "~> 1.0"},
      {:poison, "~> 3.1.0"},
      {:guardian, "~> 1.0.1"},
      {:ueberauth, "~> 0.5.0"},
      {:ueberauth_github, "~> 0.6.0"},
      {:ueberauth_google, "~> 0.7.0"},
      {:ueberauth_facebook, "~> 0.7.0"},
      {:absinthe, "~> 1.4.6"},
      {:absinthe_plug, "~> 1.4.2"},
      {:absinthe_relay, "~> 1.4.2"},
      {:absinthe_phoenix, "~> 1.4.0"},
      {:exq, "~> 0.9.1"},
      {:cors_plug, "~> 1.5.0"},
      {:uuid, "~> 1.1.8"},
      {:slugger, "~> 0.2.0"},
      {:credo, "~> 0.8.10", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5.1", only: [:dev], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
