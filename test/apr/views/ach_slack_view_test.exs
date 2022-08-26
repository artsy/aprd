defmodule Apr.Views.ACHSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.ACHSlackView
  alias Apr.Fixtures
  alias Apr.Subscriptions.Subscription

  @subscription %Subscription{theme: "ach"}

  test "disputed payment" do
    event = Fixtures.commerce_transaction_event(
      %{
        "id" => "order123",
        "seller_id" => "partner1",
        "payment_method" => "us_bank_account",
      },
      %{
        "verb" => "created",
        "transaction_type" => "dispute",
        "external_id" => "pi_123",
        "external_type" => "payment_intent",
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
              value: "<https://dashboard.stripe.com/payments/pi_123|pi_123>"
            }
          ]
        }
      ],
      text: ":alert: Dispute, do not refund this order on Stripe",
      unfurl_links: true
    }
  end
end
