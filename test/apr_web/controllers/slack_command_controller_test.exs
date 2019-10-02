defmodule AprWeb.SlackCommandControllerTest do
  use AprWeb.ConnCase
  alias Apr.Fixtures

  setup_all do
    System.put_env("SLACK_SLASH_COMMAND_TOKEN", "token")

    on_exit fn ->
      System.delete_env("SLACK_SLASH_COMMAND_TOKEN")
    end
    :ok
  end

  def receive_slack_message(token, text, channel_id) do
    build_conn()
      |> Plug.Conn.put_req_header("content-type", "application/json")
      |> post("/api/slack", %{
        "token" =>  token,
        "team_id" => "T123456",
        "team_domain" => "example",
        "channel_id" =>  channel_id,
        "channel_name" => "aprb",
        "user_id" => "U123456",
        "user_name" => "apr",
        "command" => "apr",
        "text" =>  text,
        "response_url" => "https://slack.example.com"
      })
  end

  test "requires a token" do
    conn = post(build_conn(), "/api/slack")
    assert response(conn, 403) == "Access Denied"
  end

  test "returns a 401 with an invalid token" do
    conn = receive_slack_message("invalid", "inquiries", "C123456")
    assert response(conn, 403) == "Access Denied"
  end

  describe "subscribe" do
    alias Apr.Repo
    alias Apr.Subscriptions.Subscriber
    setup do
      topic = Fixtures.create(:topic, %{name: "pretty_cool"})
      [
        topic: topic
      ]
    end
    test "subscribes to a topic when receiving subscribe command with proper token", %{topic: topic} do
      conn = receive_slack_message("token", "subscribe #{topic.name} inquiries", "wrong_channel")
      assert json_response(conn, 200) == %{"text" => ":+1: Subscribed to #{topic.name}", "response_type" => "in_channel"}
      assert Repo.one(Subscriber).channel_id == "wrong_channel"
      subscriber = Repo.get_by(Subscriber, channel_id: "wrong_channel")
      subscriber = Repo.preload(subscriber, :topics)
      assert Enum.count(subscriber.topics) == 1
      assert List.first(subscriber.topics).name == topic.name
    end
  end

  describe "unsubscribe" do
    alias Apr.Repo
    alias Apr.Subscriptions.Subscriber
    setup do
      subscriber = Fixtures.create(:subscriber, %{channel_id: "old_channel"})
      topic = Fixtures.create(:topic, %{name: "very_cool"})
      [
        subscriber: subscriber,
        topic: topic,
        subscription: Fixtures.create(:subscription, %{subscriber: subscriber, topic: topic})
      ]
    end
    test "unsubscribes from a topic when receiving unsubscribe command with proper token", %{subscriber: subscriber, topic: topic} do
      conn = receive_slack_message("token", "unsubscribe #{topic.name} inquiries", subscriber.channel_id)

      assert json_response(conn, 200) == %{"text" => ":+1: Unsubscribed from _#{topic.name}_", "response_type" => "in_channel"}
      subscriber = Repo.get_by(Subscriber, channel_id: subscriber.channel_id)
      subscriber = Repo.preload(subscriber, :topics)
      assert Enum.count(subscriber.topics) == 0
    end

    test "returns proper message when receiving unsubscribe command for non-subscribed topic", %{subscriber: subscriber} do
      conn = receive_slack_message("token", "unsubscribe random", subscriber.channel_id)

      assert json_response(conn, 200) == %{"text" => "Can't find a matching subscription to unsubscribe!", "response_type" => "in_channel"}
      subscriber = Repo.get_by(Subscriber, channel_id: subscriber.channel_id)
      subscriber = Repo.preload(subscriber, :topics)
      assert Enum.count(subscriber.topics) == 1
    end
  end
end
