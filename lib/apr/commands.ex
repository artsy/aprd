defmodule Apr.Commands do
  alias Apr.Repo
  alias Apr.Subscriptions
  alias Apr.Subscriptions.{Subscription}

  def process_command(params) do
    response =
      params
      |> Subscriptions.find_or_create_subscriber()
      |> parse_command(params)

    %{response_type: "in_channel", text: response}
  end

  defp parse_command(subscriber, %{"text" => command}) do
    cond do
      command == "topics" ->
        Subscriptions.list_topics()
        |> Enum.map(fn t -> t.name end)
        |> Enum.join("\n")

      command == "subscriptions" ->
        current_subscriptions =
          Repo.preload(subscriber, :subscriptions).subscriptions
          |> Enum.map(fn s ->
            s = Repo.preload(s, :topic)
            "*#{s.topic.name}*:#{s.routing_key || "#"}"
          end)
          |> Enum.join("\n")

        "Subscribed topics: #{current_subscriptions}"

      command =~ ~r/unsubscribe/ ->
        [_command | topic_names] = String.split(command, ~r{\s}, parts: 2)
        # add subscriptions
        removed_topics =
          List.first(topic_names)
          |> String.split(~r{\s})
          |> Enum.map(fn topic_name -> unsubscribe(subscriber, topic_name) end)
          |> Enum.reject(fn x -> x == nil end)

        if Enum.count(removed_topics) > 0 do
          ":+1: Unsubscribed from #{Enum.join(Enum.map(removed_topics, fn x -> "_#{x}_" end), " ")}"
        else
          "Can't find a matching subscription to unsubscribe!"
        end

      command =~ ~r/subscribe/ ->
        subscribed_topics =
          command
          |> String.split()
          |> Enum.drop(1)
          |> Enum.map(fn topic_name -> subscribe_to(subscriber, topic_name) end)
          |> Enum.reject(&is_nil/1)
          |> Enum.map(& &1.topic)

        ":+1: Subscribed to #{Enum.join(subscribed_topics, " ")}"

      command =~ ~r/summary/ ->
        summary(command)

      true ->
        help_message()
    end
  end

  defp help_message do
    """
    Unknown command!
    Supported commands:
    - `topics`
    - `subscriptions`
    - `subscribe <comma separated list of topics>`:
        you can also subscribe to specific routing key/verb, by using <topic>:<routing_key> format. For example: subsribe users:user.created
    - `unsubscribe <list of topics>`
    - `summary <name of topic> <optional: date in 2014-11-21 format>`
    """
  end

  defp subscribe_to(subscriber, topic_str) do
    with [topic_name | routing_key] = String.split(topic_str, ":", parts: 2),
         topic when not is_nil(topic) <- Subscriptions.get_topic_by_name(topic_name),
         routing_key <- List.first(routing_key),
         {:ok, subscription} <-
           Subscriptions.create_subscription(%{
             topic_id: topic.id,
             subscriber_id: subscriber.id,
             routing_key: routing_key || "#"
           }) do
      %{topic: topic_name, subscription: subscription}
    end
  end

  defp unsubscribe(subscriber, topic_name) do
    topic = Subscriptions.get_topic_by_name(topic_name)

    if topic do
      subscription = Repo.get_by(Subscription, subscriber_id: subscriber.id, topic_id: topic.id)

      if subscription do
        Repo.delete(subscription)
        topic_name
      end
    end
  end

  defp summary(_command) do
    ":sadbot: not supported for now, we will be back soon!"
  end
end
