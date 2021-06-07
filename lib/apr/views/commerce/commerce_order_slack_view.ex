# https://github.com/artsy/exchange/blob/master/app/events/order_event.rb
defmodule Apr.Views.CommerceOrderSlackView do
  @payments Application.get_env(:apr, :payments)

  import Apr.Views.Helper

  alias Apr.Views.CommerceHelper

  alias Apr.Subscriptions.Subscription

  def render(nil, event, routing_key) do
    generate_slack_message(event, routing_key)
  end

  def render(subscription, event, routing_key) do
    case {subscription.theme, event["verb"], event["properties"]} do
      {"fraud", "submitted", %{"mode" => "buy", "items_total_cents" => cents}} when cents >= 3_000_00 ->
        generate_slack_message(event, routing_key)
      {"fraud", "approved", %{"mode" => "offer", "currency_code" => currency_code, "items_total_cents" => cents}}
        when cents >= 9_500_00 and (currency_code == "EUR" or currency_code == "GBP") ->
        generate_slack_message(event, routing_key)
        # When subscription theme is not fraud it is nil, in this case we want to render all the messages
      {nil, _, _} ->
        generate_slack_message(event, routing_key)
      _ -> nil
    end
  end

  defp generate_slack_message(event, routing_key) do
    event
    |> get_title()
    |> build_message(event, routing_key)
  end

  defp get_title(event) do
    case {event["verb"], event["properties"]["mode"]} do
      {"submitted", "buy"} ->
        with {:ok, payment_info} <-
               @payments.payment_info(event["properties"]["external_charge_id"], event["properties"]["external_type"]) do
          "🤞 Submitted  #{format_boolean(payment_info.charge_data.liability_shift)}"
        else
          _ -> "🤞Submitted"
        end

      {"submitted", "offer"} ->
        "🤞 Offer Submitted"

      {"approved", _} ->
        ":yes: Approved"

      {"canceled", _} ->
        case event["properties"]["state_reason"] do
          "seller_lapsed" ->
            ":zzz: Seller Lapsed"

          "seller_rejected" ->
            ":soshocked: Seller Rejected"

          "seller_rejected_offer_too_low" ->
            ":soshocked: Seller Rejected - Offer too low"

          "seller_rejected_shipping_unavailable" ->
            ":soshocked: Seller Rejected - Shipping unavailable"

          "seller_rejected_artwork_unavailable" ->
            ":soshocked: Seller Rejected - Artwork unavailable"

          "seller_rejected_other" ->
            ":soshocked: Seller Rejected - other"

          "buyer_rejected" ->
            ":soshocked: Buyer Rejected"

          "buyer_lapsed" ->
            ":zzz: Buyer Lapsed"
        end

      {"refunded", _} ->
        ":sad-parrot: Refunded"

      {"fulfilled", _} ->
        ":shipitmoveit: Fulfilled"

      {"pending_approval", _} ->
        ":hourglass: Waiting Approval"

      {"pending_fulfillment", _} ->
        ":hourglass: Waiting Shipping"

      _ ->
        nil
    end
  end

  defp build_message(nil, _event, _routing_key), do: nil

  defp build_message(title, event, routing_key) do
    seller =
      CommerceHelper.fetch_participant_info(
        event["properties"]["seller_id"],
        event["properties"]["seller_type"]
      )

    buyer =
      CommerceHelper.fetch_participant_info(
        event["properties"]["buyer_id"],
        event["properties"]["buyer_type"]
      )

    %{
      text: "#{title} #{artworks_links_from_line_items(event["properties"]["line_items"])}",
      attachments: order_attachments(routing_key, event["properties"], event["object"]["id"], seller, buyer),
      unfurl_links: true
    }
  end

  defp order_attachments(_routing_key, order_properties, order_id, seller, buyer) do
    fields =
      order_attachment_fields(order_properties, seller, buyer)
      |> append_admin(seller["admin"])
      |> append_offer_fields(order_properties["mode"], order_properties)

    [
      %{
        color: "#6E1FFF",
        author_name: order_properties["code"],
        author_link: exchange_admin_link(order_id),
        title: seller["name"],
        title_link: exchange_partner_orders_link(seller["_id"]),
        fields: fields
      }
    ] ++ CommerceHelper.line_item_attachments(order_properties["line_items"])
  end

  defp append_admin(attachments, nil), do: attachments

  defp append_admin(attachments, admin),
    do: attachments ++ [%{title: "Admin", value: admin["name"], short: true}]

  defp append_offer_fields(attachments, "offer", properties),
    do:
      attachments ++
        [
          %{
            title: "List Price",
            value: format_price(properties["total_list_price_cents"], properties["currency_code"]),
            short: true
          }
        ]

  defp append_offer_fields(attachments, _, _), do: attachments

  defp order_attachment_fields(order_properties, _seller, buyer) do
    [
      %{
        title: "Purchase Method",
        value: purchase_method(order_properties),
        short: true
      },
      %{
        title: "Buyer",
        value: "<#{exchange_user_orders_link(buyer["_id"])}|#{cleanup_name(buyer["name"])}>",
        short: true
      },
      %{
        title: "Total Amount",
        value: format_price(order_properties["items_total_cents"], order_properties["currency_code"]),
        short: true
      }
    ]
  end

  defp purchase_method(order) do
    cond do
      order["mode"] == "offer" && order["impulse_conversation_id"] -> "Inquiry Offer :cashmoney:"
      true -> order["mode"]
    end
  end

  defp artworks_links_from_line_items(line_items) do
    line_items
    |> Enum.map(fn li -> "<#{artwork_link(li["artwork_id"])}| >" end)
  end
end
