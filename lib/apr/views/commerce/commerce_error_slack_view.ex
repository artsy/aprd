# https://github.com/artsy/exchange/blob/main/app/events/application_error_event.rb

defmodule Apr.Views.CommerceErrorSlackView do
  import Apr.Views.Helper
  alias Apr.Subscriptions.Subscription

  def render(%Subscription{theme: "dispute"}, _, _), do: nil
  def render(%Subscription{theme: "fraud"}, _, _), do: nil

  def render(_, event, _routing_key) do
    case event["properties"]["code"] do
      "tax_mismatch" -> tax_mismatch_message(event)
      "stripe_account_inactive" -> stripe_account_inactive_message(event)
      _ -> default_message(event)
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

    %{
      text: ":this-is-fine-fire: A *tax mismatch error* has occurred.",
      attachments: [
        %{
          fields: [
            %{
              title: "Order ID",
              value: "<#{exchange_admin_link(order_id)}|#{order_id}>",
              short: true
            },
            %{
              title: "Avalara Transaction ID",
              value: event["properties"]["data"]["tax_transaction_id"],
              short: true
            }
          ]
        }
      ],
      unfurl_links: true
    }
  end

  defp stripe_account_inactive_message(event) do
    order_id = event["properties"]["data"]["order_id"]

    %{
      text: "An order is blocked because the seller's stripe account is inactive.",
      attachments: [
        %{
          fields: [
            %{
              title: "Order: #{order_id}",
              value: "<#{exchange_admin_link(order_id)}|#{order_id}>",
              short: true
            },
            %{
              title: "Partner",
              value: event["properties"]["data"]["partner_name"],
              short: true
            },
            %{
              title: "Order Value",
              value: event["properties"]["data"]["order_value"],
              short: true
            }
          ]
        }
      ]
    }
  end
end
