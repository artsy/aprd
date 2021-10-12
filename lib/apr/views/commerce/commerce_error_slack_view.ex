# https://github.com/artsy/exchange/blob/master/app/events/application_error_event.rb

defmodule Apr.Views.CommerceErrorSlackView do
  import Apr.Views.Helper
  alias Apr.Subscriptions.Subscription

  def render(%Subscription{theme: "fraud"}, _, _), do: nil

  def render(_, event, routing_key) do
    case routing_key do
      "commerce.tax_mismatch" -> tax_mismatch_message(event)
      _ -> defaul_message(event)
    end
  end

  defp default_message(event) do
    %{
      text: ":alert: Failed submitting an order",
      attachments: [
        %{
          fields:
            [
              %{
                title: "Type",
                value: event["properties"]["type"],
                short: true
              },
              %{
                title: "Code",
                value: event["properties"]["code"],
                short: true
              }
            ] ++ data_fields(event["properties"]["data"])
        }
      ],
      unfurl_links: true
    }
  end

  defp data_fields(nil), do: []

  defp data_fields(data) do
    data
    |> Enum.map(fn {key, value} ->
      value_text =
        case key do
          "artwork_id" ->
            "<#{artwork_link(value)}|#{value}>"

          "order_id" ->
            "<#{exchange_admin_link(value)}|#{value}>"

          "seller_id" ->
            admin_partners_path = "partners/#{value}"
            "<#{admin_partners_link(admin_partners_path)}|#{value}>"

          _ ->
            value
        end

      %{
        title: key,
        value: value_text,
        short: true
      }
    end)
  end

  defp tax_mismatch_message(event) do
    order_id = event["properties"]["data"]["order_id"]
    tax_transaction = event["properties"]["data"]["tax_transaction"]

    %{
      text: ":take_my_money: A tax mismatch error has occurred.",
      attachments: [
        %{
          title: "Order ID",
          value: "<#{artwork_link(order_id)}|#{order_id}>",
          short: true
        },
        %{
          title: "Tax Transaction ID",
          value: tax_transaction["id"],
          short: true
        },
        %{
          title: "Tax Transaction Code",
          value: tax_transaction["code"],
          short: true
        },
        %{
          title: "Tax Date",
          value: format_datetime_string(tax_transaction["taxDate"]),
          short: true
        },
      ],
      unfurl_links: true
    }
  end
end
