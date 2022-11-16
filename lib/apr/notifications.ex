defmodule Apr.Notifications do
  alias Apr.Subscriptions
  alias Apr.Subscriptions.Subscription
  require Logger

  def receive_event(event, topic, routing_key) do
    Subscriptions.get_subscriptions(topic, routing_key)
    |> Enum.map(&{&1, slack_message(&1, event, topic, routing_key)})
    |> Enum.map(&post_message/1)
  end

  @spec slack_message(Subscription, Map, String, String) :: nil | Map
  defp slack_message(subscription, event, topic_name, routing_key) do
    with topic when not is_nil(topic) <- Subscriptions.get_topic_by_name(topic_name) do
      case topic.name do
        "auction_results" ->
          Apr.Views.AuctionResultsSlackView.render(subscription, event)

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

        "sellers" ->
          Apr.Views.SellerSlackView.render(subscription, event, routing_key)

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
      _ ->
        Logger.warn("Unknown Topic #{topic_name}")
        nil
    end
  end

  defp post_message({_, nil}), do: nil

  defp post_message({subscription, slack_message}) do
    Slack.Web.Chat.post_message(
      "##{subscription.subscriber.channel_name}",
      slack_message[:text],
      %{
        attachments: Poison.encode!(slack_message[:attachments]),
        unfurl_links: slack_message[:unfurl_links],
        as_user: true
      }
    )
  end
end
