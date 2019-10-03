defmodule Apr.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :routing_key, :string
      add :topic_id, references(:topics, on_delete: :nothing)
      add :subscriber_id, references(:subscribers, on_delete: :nothing)

      timestamps()
    end

    create index(:subscriptions, [:topic_id])
    create index(:subscriptions, [:subscriber_id])
  end
end
