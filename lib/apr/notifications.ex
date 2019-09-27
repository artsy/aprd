defmodule Apr.Notifications do
  import Ecto.Query
  alias Apr.{Repo, Service.SummaryService, SubscriptionHelper}
  alias Apr.Subscriptions.{Topic, Subscriber, Subscription}

  def receive_event(event, topic, routing_key) do
    event
    |> Poison.decode!()
    |> slack_message(topic, routing_key)
    |> post_message(topic, routing_key)
  end

  def slack_message(event, topic_name, routing_key) do
    topic = Repo.get_by(Topic, name: topic_name)

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
  end

  defp post_message(slack_message, topic, routing_key) do
    if slack_message != nil do
      get_topic_subscribers(topic, routing_key)
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

  defp get_topic_subscribers(topic_name, routing_key) do
    query =
      from s in Subscriber,
        join: sc in Subscription,
        on: s.id == sc.subscriber_id,
        join: t in Topic,
        on: t.id == sc.topic_id,
        where: t.name == ^topic_name,
        where: sc.routing_key == ^routing_key or is_nil(sc.routing_key) or sc.routing_key == "#"

    Repo.all(query)
  end
end
