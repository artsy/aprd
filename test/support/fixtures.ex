defmodule Apr.Fixtures do
  alias Apr.Subscriptions
  alias Apr.Events
  @review_default_attrs %{response: true, review_type: "dobar"}

  @subscriber_attrs %{
    team_id: "team_id",
    team_domain: "team_domain",
    channel_id: "channel_id",
    channel_name: "channel_name",
    user_id: "user_id",
    user_name: "user_name"
  }

  @topic_attrs %{
    name: "cool"
  }

  @subscription_default_attrs %{
    routing_key: "random.test"
  }

  def create(type, attrs \\ %{})

  def create(:subscriber, attrs) do
    {:ok, subscriber} =
      attrs
      |> Enum.into(@subscriber_attrs)
      |> Subscriptions.create_subscriber()

    subscriber
  end

  def create(:event, attrs) do
    {:ok, event} =
      attrs
      |> Events.create_event()

    event
  end

  def create(:topic, attrs) do
    {:ok, topic} =
      attrs
      |> Enum.into(@topic_attrs)
      |> Subscriptions.create_topic()

    topic
  end

  def create(:subscription, attrs) do
    subscriber = Map.get(attrs, :subscriber, create(:subscriber))
    topic = Map.get(attrs, :topic, create(:topic))

    {:ok, subscription} =
      attrs
      |> Enum.into(@subscription_default_attrs)
      |> Enum.into(%{subscriber_id: subscriber.id, topic_id: topic.id})
      |> Subscriptions.create_subscription()

    subscription
  end
end
