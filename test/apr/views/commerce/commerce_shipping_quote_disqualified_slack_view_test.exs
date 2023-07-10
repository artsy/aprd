defmodule Apr.Views.CommerceShippingQuoteDisqualifiedSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.CommerceShippingQuoteDisqualifiedSlackView

 
  test "shipping quote disqualifed event with disqualified routing_key" do
    event = Apr.Fixtures.shipping_quote_disqualified_event("disqualified")
    slack_view = CommerceShippingQuoteDisqualifiedSlackView.render(nil, event, "disqualified")
        
    assert slack_view == %{
      attachments: [
          %{
            fields: [
              %{
                title: "Exchange Admin Order",
                value: "<https://exchange.artsy.net/admin/orders/order-id-hello|order-id-hello>",
                short: true
              },
              %{
                title: "ARTA Dashboard link for Order",
                value: "<https://dashboard.arta.io/org/ARTSY/requests/123|123>",
                short: true
              }
            ]
          }
      ],
      text: ":warning: :package: Shipping quotes cannot be generated for Artsy Shipping Order #{event["properties"]["order"]["id"]}",
      unfurl_links: true
    }
  end
end
