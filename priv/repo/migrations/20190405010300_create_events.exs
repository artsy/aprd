defmodule Apr.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :payload, :map
      add :topic, :string
      add :routing_key, :string

      timestamps()
    end

  end
end
