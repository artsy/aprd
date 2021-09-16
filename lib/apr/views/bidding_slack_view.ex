defmodule Apr.Views.BiddingSlackView do
  @gravity_api Application.get_env(:apr, :gravity_api)

  import Apr.Views.Helper

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
end
