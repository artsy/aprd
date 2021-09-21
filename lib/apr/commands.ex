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
        subscriber =
          subscriber
          |> Repo.preload(subscriptions: :topic)

        subcription_list =
          subscriber.subscriptions
          |> Enum.map(&subscription_display/1)
          |> Enum.join("\n")

        "Subscribed topics: \n #{subcription_list}"

      command =~ ~r/unsubscribe/ ->
        [_command | topic_names] = String.split(command, ~r{\s}, parts: 2)
        # add subscriptions
        removed_topics =
          List.first(topic_names)
          |> String.split(",")
          |> Enum.map(fn topic_name -> unsubscribe(subscriber, topic_name) end)
          |> Enum.reject(&is_nil/1)

        if Enum.count(removed_topics) > 0 do
          ":+1: Unsubscribed from #{Enum.join(Enum.map(removed_topics, fn x -> "_#{x}_" end), " ")}"
        else
          "Can't find a matching subscription to unsubscribe!"
        end

      command =~ ~r/subscribe/ ->
        subcription_list =
          command
          |> String.split()
          |> Enum.drop(1)
          |> Enum.map(fn topic_name -> subscribe_to(subscriber, topic_name) end)
          |> Enum.reject(&is_nil/1)
          |> Repo.preload(:topic)
          |> Enum.map(&subscription_display/1)
          |> Enum.join("\n")

        ":+1: Subscribed to #{subcription_list}"

      true ->
        help_message()
    end
  end

  defp help_message do
    """
    Available commands:\n
    - *`topics`*: Will return list of current existing topics available to subscribe.\n
    - *`subscriptions`*: Will return current subscriptions of this channel.\n
    - *`subscribe <comma separated list of topics>`*: Subscribes this channel to each topic.\nyou can also subscribe to specific routing key/verb, by using _`<topic>:<routing_key>`_ format.\n
    For example: `subsribe users:user.created`\n
    - *`unsubscribe <comma separated list of topics>`*: Unsubscribes from specific topic. Use `subscruptions` command first to get list of current subscriptions first and unsubscribe from the ones you want.\n"
    """
  end

  defp parse_text(subscribe_to_text) do
    pattern = ~r/(?<topic_name>\w+)(:(?<routing_key>[\w\.]+))?(->(?<theme>\w+))?/
    Regex.named_captures(pattern, subscribe_to_text)
  end

  defp subscribe_to(subscriber, topic_str) do
    with %{"topic_name" => topic_name, "routing_key" => routing_key, "theme" => theme} <- parse_text(topic_str),
         topic when not is_nil(topic) <- Subscriptions.get_topic_by_name(topic_name),
         {:ok, subscription} <-
           Subscriptions.create_subscription(%{
             topic_id: topic.id,
             subscriber_id: subscriber.id,
             routing_key: routing_key,
             theme: theme
           }) do
      subscription
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

  defp subscription_display(%Subscription{topic: topic, routing_key: routing_key, theme: theme}) when not is_nil(theme),
    do: "*#{topic.name}*:#{routing_key || "#"}->#{theme}"

  defp subscription_display(%Subscription{topic: topic, routing_key: routing_key}),
    do: "*#{topic.name}*:#{routing_key || "#"}"
end
