defmodule Apr.Views.ACHSlackView do
  import Apr.Views.Helper

  def render(event) do
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
    seller_path = "partner/#{seller_id}"
    "<#{admin_partners_link(seller_path)}|#{seller_id}>"
  end

  defp formatted_payment_intent_link(payment_intent_id) do
    "<https://dashboard.stripe.com/payments/#{payment_intent_id}|#{payment_intent_id}>"
  end
end
