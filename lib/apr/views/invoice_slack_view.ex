defmodule Apr.Views.InvoiceSlackView do
  @gravity_api Application.get_env(:Apr, :gravity_api)
  import Apr.ViewHelper

  def render(event, routing_key) do
    partner_data = fetch_partner_data(event["properties"]["partner_id"])

    cond do
      routing_key =~ "merchantaccount" ->
        merchant_account_message(event, partner_data)

      routing_key =~ "invoicetransaction" ->
        invoice_transaction_message(event, partner_data)

      true ->
        invoice_message(event, partner_data)
    end
  end

  defp fetch_partner_data(partner_id) do
    @gravity_api.get!("/partners/#{partner_id}").body
  end

  defp merchant_account_message(event, partner_data) do
    %{
      text: ":party-parrot: #{partner_data["name"]} merchant account #{event["verb"]}",
      attachments: [],
      unfurl_links: true
    }
  end

  defp invoice_transaction_message(event, partner_data) do
    %{
      text: ":oncoming_police_car: #{event["properties"]["seller_message"]}",
      attachments: [
        %{
          fields: [
            %{
              title: "Partner",
              value: partner_data["name"],
              short: true
            },
            %{
              title: "Artworks",
              value:
                artworks_display_from_artworkgroups(
                  event["properties"]["invoice"]["artwork_groups"]
                ),
              short: false
            },
            %{
              title: "Total",
              value: format_price(event["properties"]["invoice"]["total_cents"]),
              short: true
            },
            %{
              title: "Impulse Link",
              value:
                impulse_conversation_link(
                  event["properties"]["invoice"]["impulse_conversation_id"]
                )
            },
            %{
              title: "Charge Id",
              value: event["properties"]["source_id"]
            }
          ]
        }
      ],
      unfurl_links: true
    }
  end

  defp invoice_message(event, partner_data) do
    %{
      text: ":money_with_wings: Invoice #{event["object"]["display"]}",
      attachments: [
        %{
          fields: [
            %{
              title: "Artworks",
              value: artworks_display_from_artworkgroups(event["properties"]["artwork_groups"]),
              short: false
            },
            %{
              title: "Total",
              value: format_price(event["properties"]["total_cents"]),
              short: true
            },
            %{
              title: "Partner",
              value: partner_data["name"],
              short: true
            },
            %{
              title: "Impulse Link",
              value: impulse_conversation_link(event["properties"]["impulse_conversation_id"])
            }
          ]
        }
      ],
      unfurl_links: true
    }
  end

  defp artworks_display_from_artworkgroups(artworkgroups) do
    artworkgroups
    |> Enum.map(fn ag ->
      "<#{artwork_link(ag["artwork_id"])}|#{ag["title"]} (#{ag["artists"]})>"
    end)
    |> Enum.join(", ")
  end
end
