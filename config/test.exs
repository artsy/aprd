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
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("DB_USER") || "postgres",
  password: System.get_env("DB_PASSWORD") || "postgres",
  hostname: System.get_env("DB_HOST") || "localhost",
  database: "aprd_test"
