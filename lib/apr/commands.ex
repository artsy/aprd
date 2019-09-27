defmodule Apr.Commands do
  alias Apr.{Repo, Subscriber, Topic, Subscription}
  import Ecto.Query

  def process_command(params) do
    response =
      find_or_create_subscriber(params)
      |> parse_command(params)

    %{response_type: "in_channel", text: response}
  end

  defp parse_command(subscriber, params) do
    cond do
      params[:text] == "topics" ->
        Repo.all(from topics in Topic, select: topics.name)
        |> Enum.join("\n")

      params[:text] == "subscriptions" ->
        current_subscriptions =
          Repo.preload(subscriber, :subscriptions).subscriptions
          |> Enum.map(fn s ->
            s = Repo.preload(s, :topic)
            "*#{s.topic.name}*:#{s.routing_key || "#"}"
          end)
          |> Enum.join("\n")

        "Subscribed topics: #{current_subscriptions}"

      params[:text] =~ ~r/unsubscribe/ ->
        [_command | topic_names] = String.split(params[:text], ~r{\s}, parts: 2)
        # add subscriptions
        removed_topics =
          List.first(topic_names)
          |> String.split(~r{\s})
          |> Enum.map(fn topic_name -> unsubscribe(subscriber, topic_name) end)
          |> Enum.reject(fn x -> x == nil end)

        if Enum.count(removed_topics) > 0 do
          ":+1: Unsubscribed from #{
            Enum.join(Enum.map(removed_topics, fn x -> "_#{x}_" end), " ")
          }"
        else
          "Can't find a matching subscription to unsubscribe!"
        end

      params[:text] =~ ~r/subscribe/ ->
        subscribed_topics =
          params[:text]
          |> String.split()
          |> Enum.drop(1)
          |> Enum.map(fn topic_name -> subscribe_to(subscriber, topic_name) end)

        ":+1: Subscribed to #{Enum.join(subscribed_topics, " ")}"

      params[:text] =~ ~r/summary/ ->
        summary(params[:text])

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

  defp find_or_create_subscriber(params) do
    with nil <- Repo.get_by(Subscriber, channel_id: params[:channel_id]) do
      # create new subscriber
      sub_changeset =
        Subscriber.changeset(
          %Subscriber{},
          Map.take(params, [
            :team_id,
            :team_domain,
            :channel_id,
            :channel_name,
            :user_id,
            :user_name
          ])
        )

      with {:ok, new_subscriber} <- Repo.insert(sub_changeset) do
        new_subscriber
      end
    else
      existing_subscriber -> existing_subscriber
    end
  end

  defp subscribe_to(subscriber, topic_str) do
    [topic_name | routing_key] = String.split(topic_str, ":", parts: 2)
    routing_key = List.first(routing_key) || "#"
    topic = Repo.get_by(Topic, name: topic_name)

    if topic do
      subscription =
        Ecto.build_assoc(subscriber, :subscriptions, topic_id: topic.id, routing_key: routing_key)

      Repo.insert!(subscription)
      topic_str
    end
  end

  defp unsubscribe(subscriber, topic_name) do
    topic = Repo.get_by(Topic, name: topic_name)

    if topic do
      subscription = Repo.get_by(Subscription, subscriber_id: subscriber.id, topic_id: topic.id)

      if subscription do
        Repo.delete(subscription)
        topic_name
      end
    end
  end

  defp summary(command) do
    command_parts = String.split(command, ~r{\s}) |> Enum.drop(1)

    if Enum.count(command_parts) > 0 do
      topic = Repo.get_by(Topic, name: Enum.at(command_parts, 0))

      date =
        if Enum.count(command_parts) > 1,
          do: Calendar.Date.Parse.iso8601(Enum.at(command_parts, 1)),
          else: Calendar.Date.today!("America/New_York")

      summaries =
        Repo.all(
          from s in Summary,
            where: s.summary_date == ^date and s.topic_id == ^topic.id
        )

      summaries_text =
        summaries
        |> Enum.map(fn s -> "*#{s.verb}*: #{s.total_count}" end)
        |> Enum.join(" \r\n ")

      ":chart_with_upwards_trend: Summaries for #{date}: \r\n #{summaries_text}"
    end
  end
end
