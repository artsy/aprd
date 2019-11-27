defmodule Apr.Views.BiddingSlackView do
  @gravity_api Application.get_env(:apr, :gravity_api)

  import Apr.Views.Helper

  def render(event) do
    render(nil, event)
  end

  def render(_subscription, event) do
    artwork_data = fetch_sale_artwork(event["lotId"])

    %{
      text: ":gavel: #{event["type"]} on #{artwork_data[:permalink]}",
      attachments: [
        %{
          fields: [
            %{
              title: "Amount",
              value: format_price(event["amountCents"], artwork_data[:currency]),
              short: true
            },
            %{
              title: "Estimate",
              value: format_price(artwork_data[:estimate_cents], artwork_data[:currency])
            },
            %{
              title: "Low Estimate",
              value: format_price(artwork_data[:low_estimate_cents], artwork_data[:currency]),
              short: true
            },
            %{
              title: "High Estimate",
              value: format_price(artwork_data[:high_estimate_cents], artwork_data[:currency]),
              short: true
            },
            %{
              title: "Lot number",
              value: artwork_data[:lot_number],
              short: true
            },
            %{
              title: "Paddle number",
              value: "#{event["bidder"]["paddleNumber"]}",
              short: true
            }
          ]
        }
      ],
      unfurl_links: true
    }
  end

  @spec field_value_to_i(nil | bitstring() | integer()) :: nil | integer()
  def field_value_to_i(nil), do: nil
  def field_value_to_i(value) when is_integer(value), do: value

  def field_value_to_i(value) when is_bitstring(value),
    do: field_value_to_i(String.to_integer(value))

  defp fetch_sale_artwork(lot_id) do
    sale_artwork_response = @gravity_api.get!("/sale_artworks/#{lot_id}").body

    %{
      permalink: sale_artwork_response["_links"]["permalink"]["href"],
      lot_number: sale_artwork_response["lot_number"],
      currency: sale_artwork_response["currency"],
      estimate_cents: field_value_to_i(sale_artwork_response["estimate_cents"]),
      high_estimate_cents: field_value_to_i(sale_artwork_response["high_estimate_cents"]),
      low_estimate_cents: field_value_to_i(sale_artwork_response["low_estimate_cents"])
    }
  end
end
