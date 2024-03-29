defmodule Apr.Views.CommerceTransactionCreatedSlackViewTest do
  use ExUnit.Case, async: true
  alias Apr.Views.CommerceTransactionCreatedSlackView
  alias Apr.Fixtures
  alias Apr.Subscriptions.Subscription

  @subscription %Subscription{theme: "dispute"}

  describe "render/2" do
    test "does not generate message for credit card disputes" do
      event = Fixtures.commerce_transaction_event(
        %{
          "id" => "order123",
          "seller_id" => "partner1",
          "payment_method" => "credit card",
        },
        %{
          "verb" => "created",
          "transaction_type" => "dispute",
          "external_id" => "pi_123",
          "external_type" => "payment_intent",
        }
      )
      slack_view = CommerceTransactionCreatedSlackView.render(@subscription, event, "dispute")
      assert is_nil(slack_view)
    end

    for payment_method <- ["us_bank_account", "sepa_debit"] do
      test "generates message for #{payment_method} disputes" do
        event = Fixtures.commerce_transaction_event(
          %{
            "id" => "order123",
            "seller_id" => "partner1",
            "payment_method" => unquote(payment_method),
          },
          %{
            "verb" => "created",
            "transaction_type" => "dispute",
            "external_id" => "pi_123",
            "external_type" => "payment_intent",
          }
        )
        slack_view = CommerceTransactionCreatedSlackView.render(@subscription, event, "dispute")

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
                  value: "<https://admin-partners.artsy.net/partners/partner1|partner1>"
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
  end
end
