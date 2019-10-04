defmodule Apr.Repo.Migrations.AddPartnersTopic do
  use Ecto.Migration
  alias Apr.Subscriptions

  def change do
    Subscriptions.create_topic(%{name: "partners"})
  end
end
