defmodule Apr.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :payload, :map
    field :topic, :string
    field :routing_key, :string

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:payload, :topic, :routing_key])
    |> validate_required([:payload, :topic, :routing_key])
  end
end
