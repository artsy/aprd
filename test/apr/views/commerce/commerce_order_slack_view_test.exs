defmodule Apr.Views.CommerceOrderSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.CommerceOrderSlackView
  alias Apr.Fixtures
  alias Apr.Subscriptions.Subscription
  import Mox

  @subscription %Subscription{}
  @fraud_theme_subscription %Subscription{theme: "fraud"}

  setup do
    expect(Apr.PaymentsMock, :payment_info, fn _, _ ->
      {:ok, %{charge_data: %{liability_shift: true}, card_country: "XY", zip_check: true, cvc_check: true}}
    end)

    :ok
  end

  test "submitted buy order" do
    event = Fixtures.commerce_order_event()
    slack_view = CommerceOrderSlackView.render(@subscription, event, "order.submitted")
    assert slack_view.text == "🤞 Submitted  :verified: <https://www.artsy.net/artwork/artwork1| >"
    assert slack_view[:unfurl_links] == true
  end

  test "submitted offer order" do
    event = Fixtures.commerce_offer_order()
    slack_view = CommerceOrderSlackView.render(@subscription, event, "order.submitted")
    assert slack_view.text == "🤞 Offer Submitted <https://www.artsy.net/artwork/artwork1| >"
    assert slack_view[:unfurl_links] == true
  end

  test "submitted inquiry offer order" do
    event = Fixtures.commerce_offer_order("submitted", %{"impulse_conversation_id" => "12345"})
    slack_view = CommerceOrderSlackView.render(@subscription, event, "order.submitted")
    assert slack_view.text == "🤞 Offer Submitted <https://www.artsy.net/artwork/artwork1| >"
    attachments = slack_view.attachments |> Enum.flat_map(fn a -> a.fields end) |> Enum.map(fn field -> field.value end)
    assert "Inquiry Offer :cashmoney:" in attachments
    assert slack_view[:unfurl_links] == true
  end

  test "approved order" do
    event = Fixtures.commerce_order_event("approved")
    slack_view = CommerceOrderSlackView.render(@subscription, event, "order.approved")
    assert slack_view.text == ":yes: Approved <https://www.artsy.net/artwork/artwork1| >"
    assert slack_view[:unfurl_links] == true
  end

  test "refunded order" do
    event = Fixtures.commerce_order_event("refunded")
    slack_view = CommerceOrderSlackView.render(@subscription, event, "order.refunded")
    assert slack_view.text == ":sad-parrot: Refunded <https://www.artsy.net/artwork/artwork1| >"
    assert slack_view[:unfurl_links] == true
  end

  test "fulfilled order" do
    event = Fixtures.commerce_order_event("fulfilled")
    slack_view = CommerceOrderSlackView.render(@subscription, event, "order.fulfilled")

    assert slack_view.text ==
             ":shipitmoveit: Fulfilled <https://www.artsy.net/artwork/artwork1| >"

    assert slack_view[:unfurl_links] == true
  end

  test "pending_approval order" do
    event = Fixtures.commerce_order_event("pending_approval")
    slack_view = CommerceOrderSlackView.render(@subscription, event, "order.pending_approval")

    assert slack_view.text ==
             ":hourglass: Waiting Approval <https://www.artsy.net/artwork/artwork1| >"

    assert slack_view[:unfurl_links] == true
  end

  test "pending_fulfillment order" do
    event = Fixtures.commerce_order_event("pending_fulfillment")
    slack_view = CommerceOrderSlackView.render(@subscription, event, "order.pending_fulfillment")

    assert slack_view.text ==
             ":hourglass: Waiting Shipping <https://www.artsy.net/artwork/artwork1| >"

    assert slack_view[:unfurl_links] == true
  end

  test "returns nil for subscription with fraud theme and events other than submit" do
    event = Fixtures.commerce_order_event("created")
    slack_view = CommerceOrderSlackView.render(@fraud_theme_subscription, event, "order.created")
    assert is_nil(slack_view)
  end

  test "returns nil for subscription with fraud theme and submitted orders below threshold" do
    event = Fixtures.commerce_order_event("submitted", %{"items_total_cents" => 2999_00})

    slack_view = CommerceOrderSlackView.render(@fraud_theme_subscription, event, "order.submitted")
    assert is_nil(slack_view)
  end

  test "returns message for subscription with fraud theme and total cents below threshold" do
    event = Fixtures.commerce_order_event("submitted", %{"items_total_cents" => 3000_00})

    slack_view = CommerceOrderSlackView.render(@fraud_theme_subscription, event, "order.submitted")
    refute is_nil(slack_view.text)
  end

  test "does not return message for subscription with fraud theme when offer over 10K is submitted" do
    event = Fixtures.commerce_order_event("submitted", %{"items_total_cents" => 11000_00, "currency_code" => "EUR", "mode" => "offer"})
    slack_view = CommerceOrderSlackView.render(@fraud_theme_subscription, event, "order.submitted")

    assert is_nil(slack_view)
  end

  test "does not return message for subscription with fraud theme when offer under 10K EUR is submitted" do
    event = Fixtures.commerce_order_event("submitted", %{"items_total_cents" => 4000_00, "currency_code" => "EUR", "mode" => "offer"})
    slack_view = CommerceOrderSlackView.render(@fraud_theme_subscription, event, "order.submitted")

    assert is_nil(slack_view)
  end

  test "does not return message for subscription with fraud theme when offer under 10K GBP is approved" do
    event = Fixtures.commerce_order_event("approved", %{"items_total_cents" => 4000_00, "currency_code" => "GBP", "mode" => "offer"})
    slack_view = CommerceOrderSlackView.render(@fraud_theme_subscription, event, "order.approved")

    assert is_nil(slack_view)
  end

  test "returns message for subscription with fraud theme when offer over 10K is approved" do
    event = Fixtures.commerce_order_event("approved", %{"items_total_cents" => 11000_00, "currency_code" => "EUR", "mode" => "offer"})
    slack_view = CommerceOrderSlackView.render(@fraud_theme_subscription, event, "order.approved")

    refute is_nil(slack_view.text)
  end

  test "does not return a message for subscription with fraud theme when offer under 10K and NSO" do
    event = Fixtures.commerce_order_event("approved", %{"items_total_cents" => 5000_00, "currency_code" => "EUR", "mode" => "offer"})
    slack_view = CommerceOrderSlackView.render(@fraud_theme_subscription, event, "order.approved")

    assert is_nil(slack_view)
  end

  test "does not return a message for subscription with fraud theme when offer over 10K is approved and USD" do
    event = Fixtures.commerce_order_event("approved", %{"items_total_cents" => 11000_00, "currency_code" => "USD", "mode" => "offer"})
    slack_view = CommerceOrderSlackView.render(@fraud_theme_subscription, event, "order.approved")

    assert is_nil(slack_view)
  end
end
