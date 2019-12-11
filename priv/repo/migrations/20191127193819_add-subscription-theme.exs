defmodule :"Elixir.Apr.Repo.Migrations.Add-subscription-theme" do
  use Ecto.Migration

  def change do
    alter table(:subscriptions) do
      add :theme, :string
    end
  end
end
