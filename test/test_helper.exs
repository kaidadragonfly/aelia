ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Aelia.Repo, :manual)

Supervisor.start_link(
  [{Plug.Cowboy,
    scheme: :http,
    plug: Aelia.MockServer,
    options: [port: 54200]}],
  strategy: :one_for_one)
