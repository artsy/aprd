defmodule Apr.Views.SellerSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.SellerSlackView
  import Mox

  describe "render/3" do
    test "seller event with test routing_key" do
      event = Apr.Fixtures.seller_event()
      slack_view = SellerSlackView.render(nil, event, "test")

      assert slack_view.text == ":money_with_wings: Invoice Transaction(123)"
    end

    test "merchant_account event with test routing_key" do
      event = Apr.Fixtures.seller_event(
        "external_account_restricted_soon",
        %{
          "stripe_requirements" => %{
            "deadline" => 1_546_300_800,
            "requirements" => ["external_account"]
          }
        }
      )
      slack_view = SellerSlackView.render(nil, event, "merchantaccount")

      assert slack_view == %{
        attachments: [
          %{
            fields: [
              %{
                short: true,
                title: "Requirements",
                value: "external_account"
              },
              %{
                short: true,
                title: "Stripe account ID",
                value: "<https://dashboard.stripe.com/connect/accounts/stripe_account_id/activity|stripe_account_id>"
              }
            ]
          }
        ],
        text: ":warning: Stripe account of Mocked Partner2 will be restricted by 2019-01-01 12:00 AM UTC",
        unfurl_links: true
      }
    end

    test "seller event with merchantaccount routing_key" do
      event = Apr.Fixtures.seller_event()
      slack_view = SellerSlackView.render(nil, event, "merchantaccount")

      assert slack_view.text == ":party-parrot: Mocked Partner2 merchant account created"
    end

    test "seller event invoicetransaction routing_key" do
      event = Apr.Fixtures.seller_event()
      slack_view = SellerSlackView.render(nil, event, "invoicetransaction")

      assert slack_view.text == ":oncoming_police_car: "
    end
  end
end
