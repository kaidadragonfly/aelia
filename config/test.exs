use Mix.Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :aelia, Aelia.Repo,
  username: "postgres",
  password: "postgres",
  database: "aelia_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :aelia, AeliaWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Use a mock server in place of deviant_art
config :aelia, :deviantart_base_url, "http://localhost:54200"
config :aelia, :deviantart_auth_url, "http://localhost:54200/auth"
config :aelia, :da_client_id, "TEST_DEVIANTART_CLIENT_ID"
config :aelia, :da_client_secret, "TEST_DEVIANTART_CLIENT_SECRET"
