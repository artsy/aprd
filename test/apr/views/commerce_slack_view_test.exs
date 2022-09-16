defmodule Apr.Views.CommerceSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.CommerceSlackView
  alias Apr.Subscriptions.Subscription
  alias Apr.Fixtures
  import Mox

  setup do
    expect(Apr.PaymentsMock, :payment_info, fn _, _ ->
      {:ok,
       %{
         card_country: "XY",
         zip_check: true,
         cvc_check: true,
         charge_data: %{risk_level: "high", liability_shift: true},
         billing_state: "NY"
       }}
    end)

    :ok
  end

  test "Transaction event renders transaction message" do
    event =
      Apr.Fixtures.commerce_transaction_event(%{
        "id" => "order123",
        "items_total_cents" => 2_000_000,
        "currency_code" => "USD",
        "buyer_id" => "user1",
        "buyer_type" => "user"
      })

    slack_view = CommerceSlackView.render(nil, event, "transaction.failure")

    assert slack_view.text == ":alert:"
  end

  test "Offer event renders offer message" do
    event = Apr.Fixtures.commerce_offer_event("submitted", %{"amount_cents" => 300})
    slack_view = CommerceSlackView.render(nil, event, "offer.submitted")
    assert slack_view.text == ":parrotsunnies: Counteroffer submitted"
  end

  test "Ignores offer events for fraud theme" do
    event = Apr.Fixtures.commerce_offer_event("submitted", %{"amount_cents" => 300})
    slack_view = CommerceSlackView.render(%Subscription{theme: "fraud"}, event, "offer.submitted")
    assert is_nil(slack_view)
  end

  test "Order event renders order message" do
    event = Fixtures.commerce_order_event()
    slack_view = CommerceSlackView.render(nil, event, "order.submitted")
    assert slack_view.text == "🤞 Submitted  :verified: <https://www.artsy.net/artwork/artwork1| >"
    assert slack_view[:unfurl_links] == true
  end

  test "Error event renders error message" do
    event = Apr.Fixtures.commerce_error_event()
    slack_view = CommerceSlackView.render(nil, event, "error.validation.insufficient_funds")
    assert slack_view.text == ":alert: Failed submitting an order"
  end

  test "Ignores transaction failure events for dispute theme and # routing_key" do
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

    slack_view = CommerceSlackView.render(%Subscription{routing_key: "#", theme: "dispute"}, event, "transaction.failure")
    assert is_nil(slack_view)
  end

  test "Ignores offer events for dispute theme and # routing_key" do
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

    slack_view = CommerceSlackView.render(%Subscription{routing_key: "#", theme: "dispute"}, event, "offer")
    assert is_nil(slack_view)
  end

  test "Ignores order events for dispute theme and # routing_key" do
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

    slack_view = CommerceSlackView.render(%Subscription{routing_key: "#", theme: "dispute"}, event, "order")
    assert is_nil(slack_view)
  end

  test "Ignores error events for dispute theme and # routing_key" do
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

    slack_view = CommerceSlackView.render(%Subscription{routing_key: "#", theme: "dispute"}, event, "error")
    assert is_nil(slack_view)
  end
end
