defmodule Apr.Repo.Migrations.CreateSubscribers do
  use Ecto.Migration

  def change do
    create table(:subscribers) do
      add :team_id, :string
      add :team_domain, :string
      add :channel_id, :string
      add :channel_name, :string
      add :user_id, :string
      add :user_name, :string

      timestamps()
    end
    create unique_index(:subscribers, [:channel_id], name: :subscribers_channel_id_uniq_idx)
  end
end
