defmodule Apr.Subscriptions.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscriptions" do
    field :routing_key, :string

    belongs_to :topic, Apr.Subscriptions.Topic
    belongs_to :subscriber, Apr.Subscriptions.Subscriber

    timestamps()
  end

  @required_fields ~w(topic_id subscriber_id)
  @optional_fields ~w(routing_key)

  def changeset(model, attrs) do
    model
    |> cast(attrs, @required_fields, @optional_fields)
    |> foreign_key_constraint(:topic_id)
    |> foreign_key_constraint(:subscriber_id)
  end
end
