defmodule Apr.SubscriptionsTest do
  use Apr.DataCase

  alias Apr.Subscriptions

  describe "topics" do
    alias Apr.Subscriptions.Topic

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def topic_fixture(attrs \\ %{}) do
      {:ok, topic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Subscriptions.create_topic()

      topic
    end

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      assert Subscriptions.list_topics() == [topic]
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()
      assert Subscriptions.get_topic!(topic.id) == topic
    end

    test "create_topic/1 with valid data creates a topic" do
      assert {:ok, %Topic{} = topic} = Subscriptions.create_topic(@valid_attrs)
      assert topic.name == "some name"
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscriptions.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{} = topic} = Subscriptions.update_topic(topic, @update_attrs)
      assert topic.name == "some updated name"
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Subscriptions.update_topic(topic, @invalid_attrs)
      assert topic == Subscriptions.get_topic!(topic.id)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = Subscriptions.delete_topic(topic)
      assert_raise Ecto.NoResultsError, fn -> Subscriptions.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Subscriptions.change_topic(topic)
    end
  end

  describe "subscribers" do
    alias Apr.Subscriptions.Subscriber

    @valid_attrs %{
      channel_id: "some channel_id",
      channel_name: "some channel_name",
      team_domain: "some team_domain",
      team_id: "some team_id",
      user_id: "some user_id",
      user_name: "some user_name"
    }
    @update_attrs %{
      channel_id: "some updated channel_id",
      channel_name: "some updated channel_name",
      team_domain: "some updated team_domain",
      team_id: "some updated team_id",
      user_id: "some updated user_id",
      user_name: "some updated user_name"
    }
    @invalid_attrs %{
      channel_id: nil,
      channel_name: nil,
      team_domain: nil,
      team_id: nil,
      user_id: nil,
      user_name: nil
    }

    def subscriber_fixture(attrs \\ %{}) do
      {:ok, subscriber} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Subscriptions.create_subscriber()

      subscriber
    end

    test "list_subscribers/0 returns all subscribers" do
      subscriber = subscriber_fixture()
      assert Subscriptions.list_subscribers() == [subscriber]
    end

    test "get_subscriber!/1 returns the subscriber with given id" do
      subscriber = subscriber_fixture()
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

    test "update_subscriber/2 with valid data updates the subscriber" do
      subscriber = subscriber_fixture()

      assert {:ok, %Subscriber{} = subscriber} =
               Subscriptions.update_subscriber(subscriber, @update_attrs)

      assert subscriber.channel_id == "some updated channel_id"
      assert subscriber.channel_name == "some updated channel_name"
      assert subscriber.team_domain == "some updated team_domain"
      assert subscriber.team_id == "some updated team_id"
      assert subscriber.user_id == "some updated user_id"
      assert subscriber.user_name == "some updated user_name"
    end

    test "update_subscriber/2 with invalid data returns error changeset" do
      subscriber = subscriber_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Subscriptions.update_subscriber(subscriber, @invalid_attrs)

      assert subscriber == Subscriptions.get_subscriber!(subscriber.id)
    end

    test "delete_subscriber/1 deletes the subscriber" do
      subscriber = subscriber_fixture()
      assert {:ok, %Subscriber{}} = Subscriptions.delete_subscriber(subscriber)
      assert_raise Ecto.NoResultsError, fn -> Subscriptions.get_subscriber!(subscriber.id) end
    end

    test "change_subscriber/1 returns a subscriber changeset" do
      subscriber = subscriber_fixture()
      assert %Ecto.Changeset{} = Subscriptions.change_subscriber(subscriber)
    end
  end

  describe "subscriptions" do
    alias Apr.Subscriptions.Subscription

    @valid_attrs %{routing_key: "some routing_key"}
    @update_attrs %{routing_key: "some updated routing_key"}
    @invalid_attrs %{routing_key: nil}

    def subscription_fixture(attrs \\ %{}) do
      {:ok, subscription} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Subscriptions.create_subscription()

      subscription
    end

    test "list_subscriptions/0 returns all subscriptions" do
      subscription = subscription_fixture()
      assert Subscriptions.list_subscriptions() == [subscription]
    end

    test "get_subscription!/1 returns the subscription with given id" do
      subscription = subscription_fixture()
      assert Subscriptions.get_subscription!(subscription.id) == subscription
    end

    test "create_subscription/1 with valid data creates a subscription" do
      assert {:ok, %Subscription{} = subscription} =
               Subscriptions.create_subscription(@valid_attrs)

      assert subscription.routing_key == "some routing_key"
    end

    test "create_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscriptions.create_subscription(@invalid_attrs)
    end

    test "update_subscription/2 with valid data updates the subscription" do
      subscription = subscription_fixture()

      assert {:ok, %Subscription{} = subscription} =
               Subscriptions.update_subscription(subscription, @update_attrs)

      assert subscription.routing_key == "some updated routing_key"
    end

    test "update_subscription/2 with invalid data returns error changeset" do
      subscription = subscription_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Subscriptions.update_subscription(subscription, @invalid_attrs)

      assert subscription == Subscriptions.get_subscription!(subscription.id)
    end

    test "delete_subscription/1 deletes the subscription" do
      subscription = subscription_fixture()
      assert {:ok, %Subscription{}} = Subscriptions.delete_subscription(subscription)
      assert_raise Ecto.NoResultsError, fn -> Subscriptions.get_subscription!(subscription.id) end
    end

    test "change_subscription/1 returns a subscription changeset" do
      subscription = subscription_fixture()
      assert %Ecto.Changeset{} = Subscriptions.change_subscription(subscription)
    end
  end
end
