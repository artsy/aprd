defmodule Apr.Views.CommerceOrderSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.CommerceOrderSlackView
  alias Apr.Fixtures
  import Mox

  setup do
    expect(Apr.PaymentsMock, :liability_shift_happened, fn _x -> true end)
    :ok
  end

  test "submitted buy order" do
    event = Fixtures.commerce_order_event()
    slack_view = CommerceOrderSlackView.render(event, "order.submitted")
    assert slack_view.text == "🤞 Submitted :verified: <https://www.artsy.net/artwork/artwork1| >"
    assert slack_view[:unfurl_links] == true
  end

  test "submitted offer order" do
    event = Fixtures.commerce_offer_order()
    slack_view = CommerceOrderSlackView.render(event, "order.submitted")
    assert slack_view.text == "🤞 Offer Submitted <https://www.artsy.net/artwork/artwork1| >"
    assert slack_view[:unfurl_links] == true
  end

  test "approved order" do
    event = Fixtures.commerce_order_event("approved")
    slack_view = CommerceOrderSlackView.render(event, "order.approved")
    assert slack_view.text == ":yes: Approved <https://www.artsy.net/artwork/artwork1| >"
    assert slack_view[:unfurl_links] == true
  end

  test "refunded order" do
    event = Fixtures.commerce_order_event("refunded")
    slack_view = CommerceOrderSlackView.render(event, "order.refunded")
    assert slack_view.text == ":sad-parrot: Refunded <https://www.artsy.net/artwork/artwork1| >"
    assert slack_view[:unfurl_links] == true
  end

  test "fulfilled order" do
    event = Fixtures.commerce_order_event("fulfilled")
    slack_view = CommerceOrderSlackView.render(event, "order.fulfilled")

    assert slack_view.text ==
             ":shipitmoveit: Fulfilled <https://www.artsy.net/artwork/artwork1| >"

    assert slack_view[:unfurl_links] == true
  end

  test "pending_approval order" do
    event = Fixtures.commerce_order_event("pending_approval")
    slack_view = CommerceOrderSlackView.render(event, "order.pending_approval")

    assert slack_view.text ==
             ":hourglass: Waiting Approval <https://www.artsy.net/artwork/artwork1| >"

    assert slack_view[:unfurl_links] == true
  end

  test "pending_fulfillment order" do
    event = Fixtures.commerce_order_event("pending_fulfillment")
    slack_view = CommerceOrderSlackView.render(event, "order.pending_fulfillment")

    assert slack_view.text ==
             ":hourglass: Waiting Shipping <https://www.artsy.net/artwork/artwork1| >"

    assert slack_view[:unfurl_links] == true
  end
end
