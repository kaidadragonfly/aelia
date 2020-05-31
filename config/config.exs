# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :aelia,
  ecto_repos: [Aelia.Repo]

# Configures the endpoint
config :aelia, AeliaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Zjzi2fQMZVP3O7WEMmbnBWCUkMJ4XTkIfNbon5AP1BrLvOEKKGkVeadso72o8Kdh",
  render_errors: [view: AeliaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Aelia.PubSub,
  live_view: [signing_salt: "0X8vTPj7"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :aelia, :deviantart_base_url, "https://www.deviantart.com/api/v1/oauth2"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
