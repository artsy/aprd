defmodule Apr.Views.CommerceOfferSlackView do
  import Apr.Views.Helper

  alias Apr.Views.CommerceHelper
  alias Apr.Subscriptions.Subscription

 def render(%Subscription{theme: "dispute"}, _, _), do: nil
  def render(%Subscription{theme: "fraud"}, _, _), do: nil

  def render(_, event, routing_key) do
    case routing_key do
      "offer.submitted" -> offer_submitted(event)
      "offer.pending_response" -> offer_pending_response(event)
      "partner_offer.created" -> nil
    end
  end

  defp offer_submitted(event) do
    case Map.get(event["properties"], "in_response_to", nil) do
      nil -> nil
      _ -> counter_offer_view(event)
    end
  end

  defp offer_pending_response(event) do
    seller =
      CommerceHelper.fetch_participant_info(
        event["properties"]["order"]["seller_id"],
        event["properties"]["order"]["seller_type"]
      )

    buyer =
      CommerceHelper.fetch_participant_info(
        event["properties"]["order"]["buyer_id"],
        event["properties"]["order"]["buyer_type"]
      )

    %{
      text: ":hourglass: Waiting Offer Response",
      attachments:
        CommerceHelper.line_item_attachments(event["properties"]["order"]["line_items"]) ++
          [
            %{
              fields: [
                %{
                  title: "Offer Amount",
                  value:
                    format_price(
                      event["properties"]["amount_cents"],
                      event["properties"]["order"]["currency_code"]
                    ),
                  short: true
                },
                %{
                  title: "By",
                  value: event["properties"]["from_participant"],
                  short: true
                },
                %{
                  title: "List Price",
                  value:
                    format_price(
                      event["properties"]["order"]["total_list_price_cents"],
                      event["properties"]["order"]["currency_code"]
                    ),
                  short: true
                },
                %{
                  title: "Seller",
                  value: seller["name"],
                  short: true
                },
                %{
                  title: "Buyer",
                  value: cleanup_name(buyer["name"]),
                  short: true
                }
              ],
              actions: [
                %{
                  type: "button",
                  text: "Admin Link",
                  url: exchange_admin_link(event["properties"]["order"]["id"])
                }
              ]
            }
          ]
    }
  end

  defp counter_offer_view(event) do
    seller =
      CommerceHelper.fetch_participant_info(
        event["properties"]["order"]["seller_id"],
        event["properties"]["order"]["seller_type"]
      )

    buyer =
      CommerceHelper.fetch_participant_info(
        event["properties"]["order"]["buyer_id"],
        event["properties"]["order"]["buyer_type"]
      )

    %{
      text: ":parrotsunnies: Counteroffer submitted",
      attachments:
        CommerceHelper.line_item_attachments(event["properties"]["order"]["line_items"]) ++
          [
            %{
              fields: [
                %{
                  title: "Offer Amount",
                  value:
                    format_price(
                      event["properties"]["amount_cents"],
                      event["properties"]["order"]["currency_code"]
                    ),
                  short: true
                },
                %{
                  title: "By",
                  value: event["properties"]["from_participant"],
                  short: true
                },
                %{
                  title: "Counter to",
                  value:
                    format_price(
                      event["properties"]["in_response_to"]["amount_cents"],
                      event["properties"]["order"]["currency_code"]
                    ),
                  short: true
                },
                %{
                  title: "List Price",
                  value:
                    format_price(
                      event["properties"]["order"]["total_list_price_cents"],
                      event["properties"]["order"]["currency_code"]
                    ),
                  short: true
                },
                %{
                  title: "Seller",
                  value: seller["name"],
                  short: true
                },
                %{
                  title: "Buyer",
                  value: cleanup_name(buyer["name"]),
                  short: true
                }
              ],
              actions: [
                %{
                  type: "button",
                  text: "Admin Link",
                  url: exchange_admin_link(event["properties"]["order"]["id"])
                }
              ]
            }
          ]
    }
  end
end
