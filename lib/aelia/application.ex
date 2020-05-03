defmodule Aelia.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Aelia.Repo,
      # Start the Telemetry supervisor
      AeliaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Aelia.PubSub},
      # Start the Endpoint (http/https)
      AeliaWeb.Endpoint
      # Start a worker by calling: Aelia.Worker.start_link(arg)
      # {Aelia.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Aelia.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AeliaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
