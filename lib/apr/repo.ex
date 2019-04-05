defmodule Apr.Repo do
  use Ecto.Repo,
    otp_app: :apr,
    adapter: Ecto.Adapters.Postgres
end
