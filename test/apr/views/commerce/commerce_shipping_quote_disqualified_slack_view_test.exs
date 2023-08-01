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
                value: "<https://dashboard.arta.io/org/ARTSY/requests/arta-request-id|arta-request-id>",
                short: true
              },
              %{
                short: true, 
                title: "Artwork Listed Price", 
                value: "$110,000.00"
              }
            ]
          }
      ],
      text: ":warning: :package: Shipping quotes cannot be generated for Artsy Shipping Order #{event["properties"]["order"]["id"]}",
      unfurl_links: true
    }
  end

  test "shipping quote disqualifed event when list price is not present" do
    event = Apr.Fixtures.shipping_quote_disqualified_missing_data_event("disqualified")
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
                value: "<https://dashboard.arta.io/org/ARTSY/requests/arta-request-id|arta-request-id>",
                short: true
              },
              %{
                short: true, 
                title: "Artwork Listed Price", 
                value: "N/A"
              }
            ]
          }
      ],
      text: ":warning: :package: Shipping quotes cannot be generated for Artsy Shipping Order #{event["properties"]["order"]["id"]}",
      unfurl_links: true
    }
  end
end
