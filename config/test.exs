use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :apr, AprWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :apr, Apr.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASSWORD"),
  database: "aprd_test",
  hostname: System.get_env("DB_HOST") || "localhost"
