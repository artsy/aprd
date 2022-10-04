defmodule Apr.CommandsTest do
  use Apr.DataCase

  describe ".process_command" do
    alias Apr.Repo
    alias Apr.Commands
    alias Apr.Subscriptions
    alias Apr.Subscriptions.{Subscription}

    test "when the command is `subscribe commerce:order.approved->high_risk`" do
      subscriber_attrs = %{
        "channel_id" => "1",
        "team_id" => "1",
        "team_domain" => "test",
        "text" => "subscribe commerce:order.approved->high_risk",
        "channel_name" => "test",
        "user_id" => "1",
        "user_name" => "test"
      }
      {:ok, subscriber} = Subscriptions.create_subscriber(subscriber_attrs)
      {:ok, topic} = Subscriptions.create_topic(%{name: "commerce"})

      assert Commands.process_command(subscriber_attrs) == %{response_type: "in_channel", text: ":+1: Subscribed to *commerce*:order.approved->high_risk"}

      subscription = Repo.get_by(Subscription, subscriber_id: subscriber.id, topic_id: topic.id)
      assert subscription.routing_key == "order.approved"
      assert subscription.theme == "high_risk"
    end

    test "when the command is `subscribe commerce->high_risk`" do
      subscriber_attrs = %{
        "channel_id" => "1",
        "team_id" => "1",
        "team_domain" => "test",
        "text" => "subscribe commerce->high_risk",
        "channel_name" => "test",
        "user_id" => "1",
        "user_name" => "test"
      }
      {:ok, subscriber} = Subscriptions.create_subscriber(subscriber_attrs)
      {:ok, topic} = Subscriptions.create_topic(%{name: "commerce"})

      assert Commands.process_command(subscriber_attrs) == %{response_type: "in_channel", text: ":+1: Subscribed to *commerce*:#->high_risk"}

      subscription = Repo.get_by(Subscription, subscriber_id: subscriber.id, topic_id: topic.id)
      assert subscription.routing_key == "#"
      assert subscription.theme == "high_risk"
    end
  end
end
