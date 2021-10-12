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
    assert slack_view.text == ":take_my_money: A *tax mismatch error* has occurred."

    assert Enum.map(List.first(slack_view.attachments).fields, fn field -> field.title end) == [
             "Order ID",
             "Tax Transaction ID"
           ]

    assert slack_view[:unfurl_links] == true
  end
end
