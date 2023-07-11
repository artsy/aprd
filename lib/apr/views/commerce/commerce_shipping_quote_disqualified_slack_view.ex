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
              value: formatted_arta_dashboard_link(event["properties"]["external_id"]),
              short: true
            },
            %{
              title: "Artwork Listed Price",
              value: formatted_list_price(
                event["properties"]["order"]["currency_code"],
                event["properties"]["order"]["total_list_price_cents"]
              ),
              short: true
            },
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

  defp formatted_list_price(currency_code, list_price_cents) do
    price = Decimal.new(list_price_cents)

    "#{currency_code} #{Decimal.div(price, 100)}"
  end
end
