# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :apr,
  ecto_repos: [Apr.Repo]

# Configures the endpoint
config :apr, AprWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WY/xQnrrz0N1ov6S88QSUeg/paxHLbuslyPv9TmahKbXdNiQ5r6CZdXlt7rzvroe",
  render_errors: [view: AprWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Apr.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: System.get_env("SECRET_SALT")
  ],
  check_origin: false


config :apr, authentication: [
  username: System.get_env("AUTH_USER"),
  password: System.get_env("AUTH_PASS"),
  realm: System.get_env("AUTH_REALM")
]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :apr, RabbitMQ,
  username: System.get_env("RABBITMQ_USER"),
  password: System.get_env("RABBITMQ_PASSWORD"),
  host: System.get_env("RABBITMQ_HOST"),
  heartbeat: 5

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
