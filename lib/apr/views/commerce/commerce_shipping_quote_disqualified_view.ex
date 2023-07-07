defmodule Apr.Views.CommerceShippingQuoteDisqualifiedSlackView do
  import Apr.Views.Helper

  def render(_subscription, event, routing_key) do
    %{
      text: ":warning: :package: Shipping quotes cannot be generated for Artsy Shipping Order #{event["properties"]["order"]["id"]}",
      attachments: [
        %{
          fields: [
            %{
              title: "Shipping quotes cannot be generated for Order",
              value: formatted_exchange_admin_link(event["properties"]["order"]["id"]),
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
end