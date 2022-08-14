defmodule Apr.Views.ACHSlackView do
  import Apr.Views.Helper

  def render(subscription, event = %{"verb" => "dispute_created",}, _) do
    case {subscription.theme, event["verb"], event["properties"]} do
      {"ach", "dispute_created", %{"payment_method" => "us_bank_account"}} ->
        generate_slack_message(event, "dispute_created")
      _ -> nil
    end
  end

  def render(_, _, _), do: nil

  defp generate_slack_message(event, _routing_key) do
    order_id = event["object"]["id"]
    seller_id = event["properties"]["seller_id"]
    seller_path = "partner/#{seller_id}"
    payment_intent_id = event["properties"]["external_payment_id"]
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
