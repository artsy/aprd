defmodule Apr.SubscriptionsTest do
  use Apr.DataCase

  describe "topics" do
    alias Apr.Subscriptions
    alias Apr.Fixtures

    @valid_attrs %{name: "some name"}
    @invalid_attrs %{name: nil}

    test "list_topics/0 returns all topics" do
      topic = Fixtures.create(:topic)
      assert Subscriptions.list_topics() == [topic]
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = Fixtures.create(:topic)
      assert Subscriptions.get_topic!(topic.id) == topic
    end
  end

  describe "subscribers" do
    alias Apr.Subscriptions.Subscriber
    alias Apr.Subscriptions
    alias Apr.Fixtures

    @valid_attrs %{
      channel_id: "some channel_id",
      channel_name: "some channel_name",
      team_domain: "some team_domain",
      team_id: "some team_id",
      user_id: "some user_id",
      user_name: "some user_name"
    }

    @invalid_attrs %{
      channel_id: nil,
      channel_name: nil,
      team_domain: nil,
      team_id: nil,
      user_id: nil,
      user_name: nil
    }

    test "list_subscribers/0 returns all subscribers" do
      subscriber = Fixtures.create(:subscriber)
      assert Subscriptions.list_subscribers() == [subscriber]
    end

    test "get_subscriber!/1 returns the subscriber with given id" do
      subscriber = Fixtures.create(:subscriber)
      assert Subscriptions.get_subscriber!(subscriber.id) == subscriber
    end

    test "create_subscriber/1 with valid data creates a subscriber" do
      assert {:ok, %Subscriber{} = subscriber} = Subscriptions.create_subscriber(@valid_attrs)
      assert subscriber.channel_id == "some channel_id"
      assert subscriber.channel_name == "some channel_name"
      assert subscriber.team_domain == "some team_domain"
      assert subscriber.team_id == "some team_id"
      assert subscriber.user_id == "some user_id"
      assert subscriber.user_name == "some user_name"
    end

    test "create_subscriber/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscriptions.create_subscriber(@invalid_attrs)
    end
  end

  describe "subscriptions" do
    alias Apr.Subscriptions.Subscription
    alias Apr.Subscriptions
    alias Apr.Fixtures

    setup do
      [
        subscriber: Fixtures.create(:subscriber, %{channel_id: "subscription_test"}),
        topic: Fixtures.create(:topic)
      ]
    end

    test "delete_subscription/1 deletes the subscription", %{subscriber: subscriber} do
      subscription = Fixtures.create(:subscription, %{subscriber: subscriber})
      assert {:ok, %Subscription{}} = Subscriptions.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Subscriptions.get_subscription!(subscription.id) end
    end

    test "create_subscription/1 with valid data creates a subscription", %{
      topic: topic,
      subscriber: subscriber
    } do
      assert {:ok, %Subscription{} = subscription} =
               Subscriptions.create_subscription(%{
                 topic_id: topic.id,
                 subscriber_id: subscriber.id,
                 routing_key: "some routing_key"
               })

      assert subscription.routing_key == "some routing_key"
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscriptions.create_subscription(%{routing_key: "something"})
    end
  end
end
