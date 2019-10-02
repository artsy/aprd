defmodule Apr.Notifications do
  alias Apr.Subscriptions
  require Logger

  def receive_event(event, topic, routing_key) do
    event
    |> slack_message(topic, routing_key)
    |> post_message(topic, routing_key)
  end

  def slack_message(event, topic_name, routing_key) do
    with topic when not is_nil(topic) <- Subscriptions.get_topic_by_name(topic_name) do
      case topic.name do
        "subscriptions" ->
          Apr.Views.SubscriptionSlackView.render(event)

        "inquiries" ->
          Apr.Views.InquirySlackView.render(event)

        "purchases" ->
          Apr.Views.PurchaseSlackView.render(event)

        "auctions" ->
          Apr.Views.BiddingSlackView.render(event)

        "radiation.messages" ->
          Apr.Views.RadiationMessageSlackView.render(event)

        "conversations" ->
          Apr.Views.ConversationSlackView.render(event)

        "invoices" ->
          Apr.Views.InvoiceSlackView.render(event, routing_key)

        "consignments" ->
          Apr.Views.ConsignmentsSlackView.render(event)

        "feedbacks" ->
          Apr.Views.FeedbacksSlackView.render(event)

        "sales" ->
          Apr.Views.SalesSlackView.render(event, routing_key)

        "commerce" ->
          Apr.Views.CommerceSlackView.render(event, routing_key)
      end
    else
      _ -> Logger.warn("Unknown Topic #{topic_name}")
    end
  end

  defp post_message(slack_message, topic, routing_key) do
    if slack_message != nil do
      Subscriptions.get_topic_subscribers(topic, routing_key)
      |> Enum.each(fn subscriber ->
        Slack.Web.Chat.post_message(
          "##{subscriber.channel_name}",
          slack_message[:text],
          %{
            attachments: Poison.encode!(slack_message[:attachments]),
            unfurl_links: slack_message[:unfurl_links],
            as_user: true
          }
        )
      end)
    end
  end
end
