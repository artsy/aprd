defmodule Apr.Views.ACHSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.ACHSlackView
  alias Apr.Fixtures
  alias Apr.Subscriptions.Subscription

  @subscription %Subscription{theme: "ach"}

  test "disputed payment" do
    event = Fixtures.commerce_order_event(
      "dispute_created",
      %{
        "payment_method" => "us_bank_account",
        "payment_intent_id" => "txn_1"
      }
    )
    slack_view = ACHSlackView.render(@subscription, event, "order.submitted")

    assert slack_view == %{
      attachments: [
        %{
          fields: [
            %{
              short: true,
              title: "Order ID",
              value: "<https://exchange.artsy.net/admin/orders/order123|order123>"
            },
            %{
              short: true,
              title: "Seller ID",
              value: "<https://admin-partners.artsy.net/partner/partner1|partner1>"
            },
            %{
              short: true,
              title: "Stripe payment ID",
              value: "<https://dashboard.stripe.com/payments/txn_1|txn_1>"
            }
          ]
        }
      ],
      text: ":alert: Dispute, do not refund this order on Stripe",
      unfurl_links: true
    }
  end
end
