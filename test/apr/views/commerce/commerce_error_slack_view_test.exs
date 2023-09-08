defmodule Apr.Views.CommerceErrorSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.CommerceErrorSlackView
  alias Apr.Subscriptions.Subscription

  test "commerce error slack view" do
    event = Apr.Fixtures.commerce_error_event()
    slack_view = CommerceErrorSlackView.render(%Subscription{}, event, "test_routing_key")
    assert slack_view.text == ":alert: Failed submitting an order"

    assert Enum.map(List.first(slack_view.attachments).fields, fn field -> field.title end) == [
             "Type",
             "Code",
             "order_id"
           ]

    assert slack_view[:unfurl_links] == true
  end

  test "tax mismatch error slack view" do
    event = Apr.Fixtures.tax_mismatch_error_event()
    slack_view = CommerceErrorSlackView.render(%Subscription{}, event, "commerce.tax_mismatch")
    assert slack_view.text == ":this-is-fine-fire: A *tax mismatch error* has occurred."

    assert Enum.map(List.first(slack_view.attachments).fields, fn field -> field.title end) == [
             "Order ID",
             "Avalara Transaction ID"
           ]

    assert slack_view[:unfurl_links] == true
  end

  test "stripe account inactive error slack view" do
    event = Apr.Fixtures.stripe_account_inactive_error_event()
    slack_view = CommerceErrorSlackView.render(%Subscription{}, event, "commerce.stripe_account_inactive")

    assert slack_view.text == "An order is blocked because the seller's stripe account is inactive."
    assert Enum.map(List.first(slack_view.attachments).fields, fn field -> field.title end) == [
      "Order",
      "Partner",
      "Stripe Account",
      "Order Value"
    ]

    assert Enum.map(List.first(slack_view.attachments).fields, fn field -> field.value end) == [
      "<https://exchange.artsy.net/admin/orders/order1|order1>",
      "<https://admin-partners.artsy.net/partners/partner1|Partner Name>",
      "<https://dashboard.stripe.com/connect/accounts/acct_123|acct_123>",
      "$123.45"
    ]
  end
end
