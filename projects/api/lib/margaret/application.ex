defmodule Margaret.Application do
  @moduledoc false

  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications.
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised.
    children = [
      # Start the Ecto repository.
      Margaret.Repo,
      # Start the endpoint when the application starts.
      MargaretWeb.Endpoint,
      %{
        id: Absinthe.Subscription,
        start: {Absinthe.Subscription, :start_link, [MargaretWeb.Endpoint]},
      },
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options.
    opts = [strategy: :one_for_one, name: Margaret.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MargaretWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
