defmodule Apr.Subscriptions.Subscriber do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscribers" do
    field :channel_id, :string
    field :channel_name, :string
    field :team_domain, :string
    field :team_id, :string
    field :user_id, :string
    field :user_name, :string

    has_many :subscriptions, Apr.Subscriptions.Subscription
    has_many :topics, through: [:subscriptions, :topic]

    timestamps()
  end

  @doc false
  def changeset(subscriber, attrs) do
    subscriber
    |> cast(attrs, [:team_id, :team_domain, :channel_id, :channel_name, :user_id, :user_name])
    |> validate_required([
      :team_id,
      :team_domain,
      :channel_id,
      :channel_name,
      :user_id,
      :user_name
    ])
    |> unique_constraint(:channel_id, name: :subscribers_channel_id_uniq_idx)
  end
end
