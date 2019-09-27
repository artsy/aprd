defmodule Apr.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :name, :string

      timestamps()
    end
  end
end
