defmodule Apr.Notifications do
  alias Apr.Subscriptions
  require Logger

  def receive_event(event, topic, routing_key) do
    get_subscriptions(topic, routing_key)
    |> Enum.map(&{&1, slack_message(&1, event, topic, routing_key)})
    |> Enum.map(&post_message/1)
  end

  defp get_subscriptions(topic, routing_key) do
    Subscriptions.get_topic_subscribers(topic, routing_key)
  end

  def slack_message(subscription, event, topic_name, routing_key) do
    with topic when not is_nil(topic) <- Subscriptions.get_topic_by_name(topic_name) do
      case topic.name do
        "subscriptions" ->
          Apr.Views.SubscriptionSlackView.render(subscription, event)

        "inquiries" ->
          Apr.Views.InquirySlackView.render(subscription, event)

        "purchases" ->
          Apr.Views.PurchaseSlackView.render(subscription, event)

        "auctions" ->
          Apr.Views.BiddingSlackView.render(subscription, event)

        "radiation.messages" ->
          Apr.Views.RadiationMessageSlackView.render(subscription, event)

        "conversations" ->
          Apr.Views.ConversationSlackView.render(subscription, event)

        "invoices" ->
          Apr.Views.InvoiceSlackView.render(subscription, event, routing_key)

        "consignments" ->
          Apr.Views.ConsignmentsSlackView.render(subscription, event)

        "feedbacks" ->
          Apr.Views.FeedbacksSlackView.render(subscription, event)

        "sales" ->
          Apr.Views.SalesSlackView.render(subscription, event, routing_key)

        "commerce" ->
          Apr.Views.CommerceSlackView.render(subscription, event, routing_key)

        "partners" ->
          Apr.Views.PartnersSlackView.render(subscription, event, routing_key)
      end
    else
      _ -> Logger.warn("Unknown Topic #{topic_name}")
    end
  end

  defp post_message({subscriber, slack_message}) when not is_nil(slack_message) do
    if slack_message != nil do
      Slack.Web.Chat.post_message(
        "##{subscriber.channel_name}",
        slack_message[:text],
        %{
          attachments: Poison.encode!(slack_message[:attachments]),
          unfurl_links: slack_message[:unfurl_links],
          as_user: true
        }
      )
    end
  end

  defp post_message(_), do: nil
end
