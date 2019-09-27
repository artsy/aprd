# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :apr,
  ecto_repos: [Apr.Repo],
  gravity_api: Gravity

config :apr, Gravity,
  api_url: System.get_env("GRAVITY_API_URL") || "https://stagingapi.artsy.net",
  api_token: System.get_env("GRAVITY_API_TOKEN")

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

config :apr, :metaphysics, url: System.get_env("METAPHYSICS_URL")
config :apr, :exchange, url: System.get_env("EXCHANGE_URL")

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

config :money,
  default_currency: :USD

config :artsy_auth_ex,
  token_aud: System.get_env("ARTSY_TOKEN_AUD"),
  client_id: System.get_env("ARTSY_CLIENT_ID"),
  client_secret: System.get_env("ARTSY_CLIENT_SECRET"),
  redirect_uri:
    Map.get(System.get_env(), "HOST_URL", "http://localhost:4000") <> "/auth/callback",
  site: System.get_env("ARTSY_URL"),
  authorize_url: "/oauth2/authorize",
  token_url: "/oauth2/access_token",
  allowed_roles: ["sales_admin"]

config :joken,
  default_signer: System.get_env("ARTSY_INTERNAL_SECRET")

config :slack, api_token: System.get_env("SLACK_API_TOKEN")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
