defmodule Apr.Views.ACHSlackView do
  import Apr.Views.Helper

  def render(subscription, event, _) do
    case {subscription.theme, event["properties"]["external_type"], event["verb"], event["properties"]["transaction_type"], event["properties"]["order"]["payment_method"]} do
      {"ach", "payment_intent", "created", "dispute", "us_bank_account"} ->
        generate_slack_message(event)
      _ -> nil
    end
  end

  defp generate_slack_message(event) do
    order_id = event["properties"]["order"]["id"]
    seller_id = event["properties"]["order"]["seller_id"]
    seller_path = "partner/#{seller_id}"
    payment_intent_id = event["properties"]["external_id"]
    payment_intent_link = "https://dashboard.stripe.com/payments/#{payment_intent_id}"

    %{
      text: ":alert: Dispute, do not refund this order on Stripe",
      attachments: [
        %{
          fields: [
            %{
              title: "Order ID",
              value: "<#{exchange_admin_link(order_id)}|#{order_id}>",
              short: true
            },
            %{
              title: "Seller ID",
              value: "<#{admin_partners_link(seller_path)}|#{seller_id}>",
              short: true
            },
            %{
              title: "Stripe payment ID",
              value: "<#{payment_intent_link}|#{payment_intent_id}>",
              short: true
            }
          ]
        }
      ],
      unfurl_links: true
    }
  end
end
