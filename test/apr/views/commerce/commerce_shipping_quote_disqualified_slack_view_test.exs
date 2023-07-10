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
              short: true,
              title: "Shipping quotes cannot be generated for Order",
              value: "<https://exchange-staging.artsy.net/admin/orders/order-id-hello|order-id-hello>"
              }
          ]
          }
      ],
      text: ":warning: :package: Shipping quotes cannot be generated for Artsy Shipping Order #{event["properties"]["order"]["id"]}",
      unfurl_links: true
    }
  end
end
