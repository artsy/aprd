defmodule Apr.Views.CommerceTransactionSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.CommerceTransactionSlackView

  test "adds shipping details for orders to be shipped" do
    event =
      Apr.Fixtures.commerce_transaction_event(%{
        "id" => "order123",
        "items_total_cents" => 2_000_000,
        "currency_code" => "USD",
        "seller_id" => "partner1",
        "seller_type" => "gallery",
        "buyer_id" => "user1",
        "buyer_type" => "user",
        "fulfillment_type" => "ship",
        "shipping_country" => "US",
        "shipping_name" => "Art"
      })

    slack_view = CommerceTransactionSlackView.render(event, "transaction.failed")
    titles = Enum.map(List.first(slack_view.attachments).fields, fn field -> field.title end)
    assert "Fulfillment Type" in titles
    assert "Shipping Country" in titles
    assert "Shipping Name" in titles
  end

  test "only adds fulfillment type for orders to be picked up" do
    event =
      Apr.Fixtures.commerce_transaction_event(%{
        "id" => "order123",
        "items_total_cents" => 2_000_000,
        "currency_code" => "USD",
        "seller_id" => "partner1",
        "seller_type" => "gallery",
        "buyer_id" => "user1",
        "buyer_type" => "user",
        "fulfillment_type" => "pickup"
      })

    slack_view = CommerceTransactionSlackView.render(event, "transaction.failed")
    titles = Enum.map(List.first(slack_view.attachments).fields, fn field -> field.title end)
    assert "Fulfillment Type" in titles
    assert "Shipping Country" not in titles
    assert "Shipping Name" not in titles
  end

  test "doesn't add shipping details for orders without a fulfillment type" do
    event =
      Apr.Fixtures.commerce_transaction_event(%{
        "id" => "order123",
        "items_total_cents" => 2_000_000,
        "currency_code" => "USD",
        "seller_id" => "partner1",
        "seller_type" => "gallery",
        "buyer_id" => "user1",
        "buyer_type" => "user"
      })

    slack_view = CommerceTransactionSlackView.render(event, "transaction.failed")
    titles = Enum.map(List.first(slack_view.attachments).fields, fn field -> field.title end)
    assert "Fulfillment Type" not in titles
    assert "Shipping Country" not in titles
    assert "Shipping Name" not in titles
  end
end
