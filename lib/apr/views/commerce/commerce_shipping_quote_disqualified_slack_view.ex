defmodule Apr.Views.CommerceShippingQuoteDisqualifiedSlackView do
  import Apr.Views.Helper

  def render(_subscription, event, routing_key) do
    %{
      text: ":warning: :package: Shipping quotes cannot be generated for Artsy Shipping Order #{event["properties"]["order"]["id"]}",
      attachments: [
        %{
          fields: [
            %{
              title: "Exchange Admin Order",
              value: formatted_exchange_admin_link(event["properties"]["order"]["id"]),
              short: true
            },
            %{
              title: "ARTA Dashboard link for Order",
              value: formatted_arta_dashboard_link(event["object"]["id"]),
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

  defp formatted_arta_dashboard_link(external_id) do
    "<https://dashboard.arta.io/org/ARTSY/requests/#{external_id}|#{external_id}>"
  end
end
