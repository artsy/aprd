defmodule Apr.Views.CommerceTransactionCreatedSlackView do
  import Apr.Views.Helper

  def render(subscription, event, _routing_key) do
    case {subscription.theme, event["verb"], event["properties"]} do
      {"dispute", "created", %{"external_type" => "payment_intent", "transaction_type" => "dispute", "order" => %{"payment_method" => payment_method}}} when payment_method != "credit card" ->
        generate_slack_message(event)
      _ -> nil
    end
  end

  defp generate_slack_message(event) do
    %{
      text: ":alert: Dispute, do not refund this order on Stripe",
      attachments: [
        %{
          fields: [
            %{
              title: "Order ID",
              value: formatted_exchange_admin_link(event["properties"]["order"]["id"]),
              short: true
            },
            %{
              title: "Seller ID",
              value: formatted_admin_partners_link(event["properties"]["order"]["seller_id"]),
              short: true
            },
            %{
              title: "Stripe payment ID",
              value: formatted_payment_intent_link(event["properties"]["external_id"]),
              short: true
            }
          ]
        }
      ],
      unfurl_links: true
    }
  end

  defp formatted_exchange_admin_link(order_id) do
    "<#{exchange_admin_link(order_id)}|#{order_id}>"
  end

  defp formatted_admin_partners_link(seller_id) do
    seller_path = "partners/#{seller_id}"
    "<#{admin_partners_link(seller_path)}|#{seller_id}>"
  end

  defp formatted_payment_intent_link(payment_intent_id) do
    "<https://dashboard.stripe.com/payments/#{payment_intent_id}|#{payment_intent_id}>"
  end
end
