defmodule Apr.Repo.Migrations.AddEventIndex do
  use Ecto.Migration

  def change do
    create index(:events, [:routing_key], comment: "Index routing_key")
    create index(:events, [:topic], comment: "Index topid")
    create index(:events, [:inserted_at], comment: "Index inserted_at")
    create index(:events, [:payload], using: :gin, comment: "Index payload")
  end
end
