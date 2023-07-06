defmodule Apr.Views.CommerceShippingQuoteDisqualifiedSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.CommerceShippingQuoteDisqualifiedSlackView

  test "shipping quote disqualifed event with disqualified routing_key" do
    event = Apr.Fixtures.shipping_quote_disqualified_event("disqualified")
    slack_view = CommerceShippingQuoteDisqualifiedSlackView.render(nil, event, "disqualified")
    # print -----
    IO.inspect(event)
    
      assert slack_view == %{
        attachments: [
          %{
            fields: [
              %{
                short: true,
                title: "Shipping quotes cannot be generated for Order",
                value: "FIX_ME"
              }
            ]
          }
        ],
        text: ":warning: Shipping quotes cannot be generated for Artsy Shipping Order farts",
        unfurl_links: true
      }
    end
end
